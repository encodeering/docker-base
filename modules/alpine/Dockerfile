FROM scratch
ADD  rootfs.tar.xz any.tar.gz /
RUN  apk fix \
 &&  apk add bash

FROM scratch
COPY --from=0 / .
ENV  LANG=C.UTF-8