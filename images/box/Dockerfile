# Image of the "box" machine. Keep machine images minimal: only the tools the
# challenge needs (here bash; ls, chmod, find, sed... come from busybox).
# No sudo, no systemd, no compilers, no package manager.
FROM docker.io/library/alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
RUN apk add --no-cache bash \
 && addgroup -g 1000 student \
 && adduser -D -u 1000 -G student -h /home/student -s /bin/bash student \
 # Nothing is installed at run time: drop the package manager too (removing
 # its files is smaller than "apk del", which rewrites the package database).
 && rm -rf /sbin/apk /usr/lib/libapk.so* /etc/apk /lib/apk /var/cache/apk
# Run as the unprivileged student user (pod machines always run as 1000:1000).
USER 1000:1000
WORKDIR /home/student
CMD ["bash"]
