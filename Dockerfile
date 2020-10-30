FROM debian:stable-slim

LABEL maintainer="Michael Nival <docker@mn-home.fr>" \
	name="debian-chrony" \
	description="Debian Stable with the package chrony" \
	docker.cmd="docker run -d -p 123:123/udp --cap-add=SYS_TIME --cap-add=SYS_RESOURCE --name chrony mnival/debian-chrony"

RUN printf "deb http://ftp.debian.org/debian/ stable main\ndeb http://ftp.debian.org/debian/ stable-updates main\ndeb http://security.debian.org/ stable/updates main\n" >> /etc/apt/sources.list.d/stable.list && \
	cat /dev/null > /etc/apt/sources.list && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt update && \
	apt -y --no-install-recommends full-upgrade && \
	adduser --force-badname --system --group --quiet --gecos "Chrony daemon" --home /var/lib/chrony --no-create-home --uid 110 _chrony && \
	adduser --system --gecos "Chrony daemon" --ingroup _chrony --home /var/lib/chrony/ _chrony --uid 110 --force-badname && \
	apt install -y --no-install-recommends chrony && \
	echo "UTC" > /etc/timezone && \
	rm /etc/localtime && \
	dpkg-reconfigure tzdata && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/alternatives.log /var/log/dpkg.log /var/log/apt/ /var/cache/debconf/*-old

RUN ln -s /dev/stdout /var/log/chrony/rawmeasurements.log && \
	ln -s /dev/stdout /var/log/chrony/measurements.log && \
	ln -s /dev/stdout /var/log/chrony/statistics.log && \
	ln -s /dev/stdout /var/log/chrony/tracking.log && \
	ln -s /dev/stdout /var/log/chrony/rtc.log && \
	ln -s /dev/stdout /var/log/chrony/refclocks.log && \
	ln -s /dev/stdout /var/log/chrony/tempcomp.log

ADD start-chrony /usr/local/bin/

ENV chronyconf.pool="0.debian.pool.ntp.org iburst;1.debian.pool.ntp.org iburst;2.debian.pool.ntp.org iburst" \
	chronyconf.keyfile="/etc/chrony/chrony.keys" \
	chronyconf.driftfile="/var/lib/chrony/chrony.drift" \
	#chronyconf.log="tracking measurements statistics" \
	chronyconf.logdir="/var/log/chrony" \
	chronyconf.maxupdateskew="100.0" \
	chronyconf.rtcsync="" \
	chronyconf.makestep="1 3" \
	chrony.uid=110 \
	chrony.gid=110 \
	chrony.args="-F -1"

EXPOSE 123/udp

ENTRYPOINT ["start-chrony"]
