ARG from=ubuntu:18.04
FROM ${from} as build

#
#  Install build tools
#
RUN apt-get update
RUN apt-get install -y devscripts equivs git quilt gcc doxygen graphviz libjson-perl libssl-dev libtalloc-dev libkqueue-dev

#
#  Create build directory
#
RUN mkdir -p /usr/local/src/repositories
WORKDIR /usr/local/src/repositories

#
#  Shallow clone the FreeRADIUS source
#
ARG source=https://github.com/FreeRADIUS/freeradius-server.git

RUN git clone ${source}
WORKDIR freeradius-server

#
#  Install build dependencies
#
RUN if [ -e ./debian/control.in ]; then \
        debian/rules debian/control; \
    fi; \
    echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control

#
#  Build the server
#
RUN ./configure --with-dhcp --with-experimantal-modules --enable-developer
RUN make -j2 deb
#
#  Clean environment and run the server
#
FROM ${from}
COPY --from=build /usr/local/src/repositories/*.deb /tmp/

ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_USER=radius
ENV DB_PASS=radpass
ENV DB_NAME=radius
ENV RADIUS_KEY=testing123
ENV RAD_CLIENTS=10.0.0.0/24
ENV RAD_DEBUG=no
ENV IMAP_HOST=localhost
ENV IMAP_PORT=993
ENV IMAP_PROTO=tls
ENV IMAP_CERT=
ENV IMAP_CA=
ENV IMAP_KEY=


RUN apt-get update \
    && apt-get install -y /tmp/*.deb \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* /tmp/*.deb \
    \
    && ln -s /etc/freeradius /etc/raddb

RUN rm /etc/freeradius/mods-enabled/soh
COPY default /etc/freeradius/sites-enabled/default

COPY docker-entrypoint.sh /
VOLUME ["/etc/freeradius/"]
EXPOSE 1812/udp 1813/udp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeradius"]
