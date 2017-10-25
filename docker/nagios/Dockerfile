FROM jasonrivers/nagios

RUN apt-get update     \ 
 && apt-get install -y \
    libfile-pid-perl   \
    libconfuse-dev     \
    python2.7          \ 
    python-requests    \
 && apt-get clean      \
 && rm -rf /var/lib/apt/lists/* 

WORKDIR /tmp/nsca-ng

RUN git clone https://github.com/weiss/nsca-ng.git /tmp/nsca-ng \ 
 && ./autogen.sh                              \
 && ./configure                               \
        --prefix="${NAGIOS_HOME}"             \
        --enable-server                       \
        --disable-client                      \
 && make                                      \
 && make install                              \
 && cp /opt/nagios/etc/nsca-ng.cfg /orig/etc/ \
 && rm -rf /tmp/nsca-ng

COPY nsca-ng.init /etc/sv/nsca-ng/run
COPY radar.init /etc/sv/radar/run

RUN ln -sf /etc/sv/* /etc/service

EXPOSE 5668

CMD [ "/usr/local/bin/start_nagios" ]
