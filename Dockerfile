FROM gitpod/workspace-full-vnc

COPY temp/emacs-vm.qcow2 /home/gitpod/emacs-vm.qcow2

COPY temp/qemu-python.tar.gz /home/gitpod/qemu-python.tar.gz
RUN ls -l
RUN tar -xzf /home/gitpod/qemu-python.tar.gz
