FROM docker.io/library/ubuntu

MAINTAINER "@svk"

LABEL description="Unit Container"
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install curl gnupg apt-utils build-essential nodejs npm golang net-tools libcap2-bin git

#RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install build-essential nodejs npm golang
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nodejs node-gyp php-dev libphp-embed libperl-dev python-dev ruby-dev libssl-dev libpcre2-dev libpcre3-dev openjdk-16-jre-headless pip
RUN curl -sL https://nginx.org/keys/nginx_signing.key | apt-key add -
RUN echo "deb https://packages.nginx.org/unit/ubuntu/ groovy unit" > /etc/apt/sources.list.d/unit.list
RUN echo "deb-src https://packages.nginx.org/unit/ubuntu/ groovy unit" >> /etc/apt/sources.list.d/unit.list
RUN apt-get update
#RUN curl -sL https://deb.nodesource.com/setup_X.Y | bash -
RUN DEBIAN_FRONTEND="noninteractive" apt install -y unit
RUN DEBIAN_FRONTEND="noninteractive" apt install -y unit-dev unit-go unit-jsc11 unit-jsc13 unit-perl unit-php unit-python2.7 unit-python3.8 unit-ruby 
RUN DEBIAN_FRONTEND="noninteractive" apt install -y unit-dev unit-python2.7 unit-python3.8
RUN pip install flask flasgger gitpython
COPY ./entrypoint.sh /entrypoint.sh
RUN mkdir /var/lib/unit/certs 
RUN touch /var/run/unit.pid
RUN chown unit:unit /var/run/unit.pid
RUN chmod 777 /var/run/unit.pid
RUN chmod 755 /entrypoint.sh
#RUN setcap cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read,38,39,40=+ep /usr/sbin/unitd
RUN mkdir /home/unit
RUN chown unit:unit /home/unit
RUN usermod -d /home/unit unit
RUN usermod -s /bin/bash unit
#USER unit
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 8888 8080 80
