FROM scratch
ADD  ./rootfs/rootfs.tar.xz ./rootfs/any.tar.gz /
RUN  apk fix \
 &&  apk add bash \
 &&  rm -fr /var/cache/apk/*

FROM scratch
COPY --from=0 / .
ENV  LANG=C.UTF-8