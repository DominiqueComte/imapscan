FROM debian:latest

# timezone name that can be overridden when building the container
ARG CTNR_TZ=UTC

# shell to start from Kitematic
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
# timezone to set
ENV CTNR_TZ=${CTNR_TZ}

# install dependencies
RUN apt-get update && \
    apt-get install -y \
      cron \
      imapfilter \
      nano \
      python \
      python-pip \
      python-setuptools \
      pyzor \
      razor \
      rsyslog \
      spamassassin \
      spamc \
      unzip \
      wget \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    /usr/bin/env python -m pip install wheel && \
    /usr/bin/env python -m pip install docopt==0.6.2

WORKDIR /root

# install isbg
RUN wget https://github.com/dc55028/isbg/archive/master.zip && \
    mv master.zip isbg.zip && \
    unzip isbg.zip && \
    cd isbg-master && \
    python setup.py install && \
    cd .. && \
    rm -Rf isbg-master && \
    rm isbg.zip

ADD files/* /root/

# prepare directories and files
RUN mkdir /root/accounts ; \
    mkdir /root/.imapfilter ; \
    mkdir -p /var/spamassassin/bayesdb ; \
    chown -R debian-spamd:mail /var/spamassassin ; \
    chmod u+x startup ; \
    chmod u+x *.sh ; \
    crontab cron_scans && rm cron_scans ; \
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/spamassassin ; \
    sed -i 's/CRON=0/CRON=1/' /etc/default/spamassassin ; \
    sed -i 's/^OPTIONS=".*"/OPTIONS="--allow-tell --max-children 5 --helper-home-dir -u debian-spamd -x --virtual-config-dir=\/var\/spamassassin -s mail"/' /etc/default/spamassassin ; \
    echo "bayes_path /var/spamassassin/bayesdb/bayes" >> /etc/spamassassin/local.cf ; \
    echo "allow_user_rules 1" >> /etc/spamassassin/local.cf ; \
    mv 9*.cf /etc/spamassassin/ ; \
    echo "alias logger='/usr/bin/logger -e'" >> /etc/bash.bashrc ; \
    echo "LANG=en_US.UTF-8" > /etc/default/locale ; \
    if [ -e "/usr/share/zoneinfo/${CTNR_TZ}" ]; then \
      unlink /etc/localtime ; \
      ln -s "/usr/share/zoneinfo/${CTNR_TZ}" /etc/localtime ; \
      unlink /etc/timezone ; \
      ln -s "/usr/share/zoneinfo/${CTNR_TZ}" /etc/timezone ; \
      dpkg-reconfigure -f noninteractive tzdata ; \
    fi

# volumes
VOLUME /var/spamassassin
VOLUME /root/.imapfilter
VOLUME /root/accounts

CMD /root/startup && tail -n 0 -F /var/log/*.log
