FROM j2a2m2all/guix-git-python-qemu:latest

COPY qemu-img.qcow2 /qemu-img.qcow2

ENV hda=/qemu-img.qcow2
ENV m=2048
ENV vnc=100

ENTRYPOINT /run/current-system/bin/qemu-system-x86_64 \
    -enable-kvm \
    -hda $hda \
    -m $m \
    -vga virtio \
    -vnc :$vnc
