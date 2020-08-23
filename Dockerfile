ARG from=ubuntu:18.04
FROM ${from} as build

RUN apt-get update
RUN apt-get install -y devscripts equivs git quilt gcc doxygen graphviz libjson-perl libssl-dev libtalloc-dev make build-essential git automake autoconf libtool ca-certificates libhiredis-dev libpam-dev pandoc libjson-c-dev  default-libmysqlclient-dev

RUN mkdir -p /usr/local/src/repositories
WORKDIR /usr/local/src/repositories

#ARG source=https://github.com/FreeRADIUS/freeradius-server.git
COPY freeradius-server-7ca99a57b6dd34eda228cb86a93f4f1a2175c372 freeradius-server-7ca99a57b6dd34eda228cb86a93f4f1a2175c372
COPY .git .git
#RUN git clone ${source}
WORKDIR freeradius-server-7ca99a57b6dd34eda228cb86a93f4f1a2175c372

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




# EMAIL SMTP SETTINGS

# smtp server
ENV SMTP_SERVER=gmail.com
# smtp server port
ENV SMTP_PORT=465
# smtp username
ENV SMTP_USER=admin@gmail.com
# smtp user password
ENV SMTP_PASS=superstrong_password
# module will send errors to this mailbox
ENV SMTP_ADMIN_EMAIL=who_will_receive_email@example.com
# can be different than SMTP_USER like Envelope-from
ENV SMTP_SENDER_EMAIL=admin@gmail.com
# subject of this mail can be useful for filters etc.
ENV SMTP_SUBJECT="Radius: Failed login attempt"



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
    && apt-get install -yy /tmp/*.deb \
    && ln -s /etc/freeradius /etc/raddb

RUN rm /etc/freeradius/mods-enabled/soh
#COPY raddb /etc/freeradius
COPY default /etc/freeradius/sites-enabled/default
COPY docker-entrypoint.sh /
VOLUME ["/etc/freeradius/"]
EXPOSE 1812/udp 1813/udp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeradius"]
