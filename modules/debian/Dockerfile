FROM scratch
ARG    rootfs
ADD  ${rootfs} /
ENV  DEBIAN_FRONTEND=noninteractive \
     LANG=C.UTF-8                   \
     PS1='\u@\h \W\$ '
