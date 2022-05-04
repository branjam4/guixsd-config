FROM gitpod/workspace-full-vnc

USER root

COPY temp/emacs-vm.qcow2 /emacs-vm.qcow2

COPY temp/qemu-python.tar.gz /tmp/qemu-python.tar.gz
RUN tar -xzf /tmp/qemu-python.tar.gz && rm -f /tmp/qemu-python.tar.gz
