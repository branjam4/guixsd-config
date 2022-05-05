FROM gitpod/workspace-full-vnc

USER root

COPY temp/emacs VM/emacs-vm.qcow2 /emacs-vm.qcow2

COPY temp/qemu Docker relocatable Binary/qemu-python.tar.gz /tmp/qemu-python.tar.gz
RUN tar -xzf /tmp/qemu-python.tar.gz && rm -f /tmp/qemu-python.tar.gz
