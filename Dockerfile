ARG from=ubuntu:18.04
FROM ${from} as build

RUN apt-get update
RUN apt-get install -y devscripts equivs git quilt gcc doxygen graphviz libjson-perl libssl-dev libtalloc-dev libkqueue-dev libmysqlclient-dev make build-essential git automake autoconf libtool ca-certificates libhiredis-dev libpam-dev pandoc libjson-c-dev

RUN mkdir -p /usr/local/src/repositories
WORKDIR /usr/local/src/repositories

ARG source=https://github.com/FreeRADIUS/freeradius-server.git

RUN git clone ${source}
WORKDIR freeradius-server

RUN if [ -e ./debian/control.in ]; then \
        debian/rules debian/control; \
    fi; \
    echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control

RUN ./configure --with-dhcp --with-experimantal-modules --enable-developer
RUN make -j2 deb
FROM ${from}
COPY --from=build /usr/local/src/repositories/*.deb /tmp/

ENV SQL_HOST=localhost
ENV SQL_PORT=3306
ENV SQL_USER=radius
ENV SQL_PASS=radpass
ENV SQL_DB_NAME=radius
ENV SQL_DRIVER=mysql
ENV RADIUS_KEY=testing123

### Expired cache will be deleted in 
### 30 days =  2592000 seconds
ENV CACHE_TIME=2592000

### timeout to response
ENV IMAP_TIMEOUT=5s

### Imap module it's curl in background so here can be smtp://localhost:25
ENV IMAP_URI=imap://localhost:993

###
#ENV IMAP_PROTO=tls
#ENV IMAP_CERT=
#ENV IMAP_CA=
#ENV IMAP_KEY=
#ENV IMAP_KEY_PASS=
ENV FR_LIBRARY_PATH=/usr/lib/freeradius

RUN apt-get update \
    && apt-get install -y /tmp/*.deb \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* /tmp/*.deb \
    \
    && ln -s /etc/freeradius /etc/raddb

RUN rm /etc/freeradius/mods-enabled/soh
COPY raddb /etc/freeradius
COPY default /etc/freeradius/sites-enabled/default
COPY mods-available/* /etc/freeradius/mods-enabled/

COPY docker-entrypoint.sh /
VOLUME ["/etc/freeradius/"]
EXPOSE 1812/udp 1813/udp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["env FR_LIBRARY_PATH=/usr/lib/freeradius freeradius"]
