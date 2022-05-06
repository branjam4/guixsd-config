FROM gitpod/workspace-full-vnc

USER root

COPY temp/emacs-vm.qcow2 /emacs-vm.qcow2

COPY temp/qemu-python.tar.gz /qemu-python.tar.gz
RUN ls -l
RUN tar -xzf /qemu-python.tar.gz
