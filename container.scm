(use-modules
 (gnu)
 (gnu system linux-container)
 (gnu services shepherd)
 (gnu services mcron)
 (guix)
 (guix utils)
 (guix profiles)
 (guix packages)
 (srfi srfi-1))
(use-service-modules desktop networking ssh sddm xorg spice)
(use-package-modules base xorg)

(define vm-image-motd (plain-file "motd" "
\x1b[1;37mThis is the GNU system.  Welcome!\x1b[0m

This instance of Guix is a template for virtualized environments.
You can reconfigure the whole system by adjusting /etc/config.scm
and running:

  guix system reconfigure /etc/config.scm

Run '\x1b[1;37minfo guix\x1b[0m' to browse documentation.

\x1b[1;33mConsider setting a password for the 'root' and 'guest' \
accounts.\x1b[0m
"))

;;; XXX: Xfce does not implement what is needed for the SPICE dynamic
;;; resolution to work (see:
;;; https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/142).  Workaround it
;;; by manually invoking xrandr every second.
(define auto-update-resolution-crutch
  #~(job '(next-second)
         (lambda ()
           (setenv "DISPLAY" ":0.0")
           (setenv "XAUTHORITY" "/home/guest/.Xauthority")
           (execl (string-append #$xrandr "/bin/xrandr") "xrandr" "-s" "0"))
         #:user "guest"))

(define updatedb-job
       ;; Run 'updatedb' at 3AM every day.  Here we write the
       ;; job's action as a Scheme procedure.
       #~(job '(next-minute-from (next-hour '(4 20)) '(28))
              (lambda ()
                (execl (string-append #$findutils "/bin/updatedb")
                       "updatedb"
                       "--prunepaths=/tmp /var/tmp /gnu/store"))
              "updatedb"))

(operating-system
 (locale "en_US.utf8")
 (locale-libcs (list (canonical-package glibc)))
 (timezone "America/Los_Angeles")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "chuwix")
 (users (cons* (user-account
                (name "emacsuser")
                (comment "Emacs User")
                (group "users")
                (home-directory "/home/emacsuser")
                (supplementary-groups
                 '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))
 (packages
  (append
      (map specification->package
           '("i3-wm"
             "i3status"
             "dmenu"
             "st"
             "nss-certs"
             "gnome-disk-utility"
             "ntfs-3g"
             "gvfs"
             "docker-cli"
             "picom"
             "dunst"
             "vlc"
             "nvi"
             "tigervnc-server"
             "stumpwm-with-slynk"
             "sbcl-stumpwm-swm-gaps"
             "emacs-stumpwm-mode"
             "sbcl-stumpwm-globalwindows"
             "sbcl-stumpwm-ttf-fonts"
             "font-iosevka-aile"
             "font-iosevka"
             "sbcl-stumpwm-stumptray"
             "sbcl-stumpwm-net"))
      %base-packages))
 ;; Our /etc/sudoers file.  Since 'guest' initially has an empty password,
 ;; allow for password-less sudo.
 (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))

 (services
  (append
   (list (service openssh-service-type
                  (openssh-configuration
                   (allow-empty-passwords? #t)
                   (gateway-ports? #t)))
         (service slim-service-type
                  (slim-configuration
                   (auto-login? #t)
                   (default-user "emacsuser")
                   (xorg-configuration
                    (xorg-configuration
                     ;; The QXL virtual GPU driver is added to provide
                     ;; a better SPICE experience.
                     (modules (cons xf86-video-qxl
                                    %default-xorg-modules))
                     (keyboard-layout keyboard-layout)))))

         (service spice-vdagent-service-type)
         (service xfce-desktop-service-type)
         (simple-service 'my-cron-jobs mcron-service-type
                         (list updatedb-job auto-update-resolution-crutch)))
   %base-services))
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets '( "/dev/vda"))
   (terminal-outputs '(console))))
 (file-systems
  (cons* (file-system
          (mount-point "/")
          (device "/dev/vda1")
          (type "ext4"))
         %base-file-systems)))
