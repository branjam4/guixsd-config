;; This is an operating system configuration generated
;; by the graphical installer.

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
(use-service-modules desktop networking ssh sddm xorg docker)
(use-package-modules base)

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
                (name "branjam")
                (comment "Brandon Ellington")
                (group "users")
                (home-directory "/home/branjam")
                (supplementary-groups
                 '("wheel" "netdev" "audio" "video" "docker")))
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
          "stumpwm-with-slynk"
          "sbcl-stumpwm-swm-gaps"
          "emacs-stumpwm-mode"
          "sbcl-stumpwm-globalwindows"
          "sbcl-stumpwm-ttf-fonts"
          "sbcl-stumpwm-stumptray"
          "sbcl-stumpwm-net"))
   %base-packages))
 (services
  (append
   (list (service openssh-service-type
                  (openssh-configuration
                   (allow-empty-passwords? #t)
                   (gateway-ports? #t)))
         (set-xorg-configuration
          (xorg-configuration
           (keyboard-layout keyboard-layout)))
         (service xfce-desktop-service-type)
         (simple-service 'my-cron-jobs mcron-service-type
                         (list updatedb-job))
         (service docker-service-type)
         (service singularity-service-type))
   %desktop-services))
 (bootloader
  (bootloader-configuration
   (bootloader grub-bootloader)
   (targets '( "/dev/sda"))
   (keyboard-layout keyboard-layout)))
 (swap-devices (list (swap-space (target "/dev/sda1"))))
 (file-systems
  (cons* (file-system
          (mount-point "/")
          (device
           (uuid "ca3c2ded-fc9c-4e20-a647-2c34bb5b0187"
                 'ext4))
          (type "ext4"))
         %base-file-systems)))
