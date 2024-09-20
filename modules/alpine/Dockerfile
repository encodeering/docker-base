FROM scratch
ADD  ./rootfs/rootfs.fix.sh /
ADD  ./rootfs/rootfs.tar.xz /
RUN  apk fix \
 &&  apk --no-cache add bash shadow \
 &&  bash rootfs.fix.sh \
 &&  rm   rootfs.fix.sh \
 &&  apk del            bash shadow \
 &&  rm -fr /var/cache/apk/*

FROM scratch
COPY --from=0 / .
ENV  LANG=C.UTF-8      \
     PS1='\u@\h \W\$ '
