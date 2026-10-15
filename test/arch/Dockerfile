FROM --platform=linux/amd64 archlinux:latest
RUN curl -sSL -o /etc/pacman.conf https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf \
 && sed -i 's/^\[options\]/[options]\nDisableSandbox/' /etc/pacman.conf \
 && pacman -Syu --noconfirm sudo
RUN useradd -m -G wheel -s /bin/bash tester \
 && echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/zz-test-wheel \
 && chmod 440 /etc/sudoers.d/zz-test-wheel
COPY systemctl /usr/local/bin/systemctl
RUN chmod +x /usr/local/bin/systemctl
USER tester
WORKDIR /home/tester
ENV TERM=xterm
