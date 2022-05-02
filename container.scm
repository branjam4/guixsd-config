(use-modules
 (gnu)
 (gnu system linux-container)
 (gnu services shepherd)
 (guix)
 (guix utils)
 (guix profiles)
 (guix packages)
 (srfi srfi-1))
(use-service-modules spice dbus)
(use-package-modules base certs python version-control virtualization)

(operating-system
 (locale "en_US.utf8")
 (locale-libcs (list (canonical-package glibc)))
 (timezone "America/Los_Angeles")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "qemudock")
 (users %base-user-accounts)
 (packages
  (append
      (list qemu git nss-certs python)
      %base-packages))

 (services (append
               (list (dbus-service) (service spice-vdagent-service-type))
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
