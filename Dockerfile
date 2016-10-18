FROM ubuntu:xenial

ENV PLEX_INSTALL_URL=https://downloads.plex.tv/plex-media-server/1.2.2.2857-d34b464/plexmediaserver_1.2.2.2857-d34b464_amd64.deb

RUN apt-get update && apt-get install -y curl

# the number of plugins that can run at the same time
ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6

# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
ENV PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000

# where the mediaserver should store the transcodes
ENV PLEX_MEDIA_SERVER_TMPDIR=/transcode

# uncomment to set it to something else
ENV PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config"

# the username that PMS should run as. Definitely do not want to change this
ENV PLEX_MEDIA_SERVER_USER=plex

# The UID to map the plex user to. You *do* want this, for host file perms
ENV PLEX_MEDIA_SERVER_USER_UID="-1"

RUN curl -Lo /tmp/init.deb https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb && \
	dpkg -i /tmp/init.deb && \
	rm /tmp/init.deb

RUN curl -o /tmp/plex.deb $PLEX_INSTALL_URL && \
	dpkg -i /tmp/plex.deb && \
	rm /tmp/plex.deb

ADD run.sh /
RUN chmod +x /run.sh

RUN mkdir -p "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"

EXPOSE 32400
VOLUME ["/config" "/media" "/transcode"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["sh", "-c", "(/run.sh &) && sleep 1 && tail -f \"$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Logs/\"*" ]
# CMD ["sh", "-c", "/run.sh" ]
