FROM debian:stretch
#MAINTAINER yigal@publysher.nl

ENV USERID $tenantuserid
#ENV GID $tenantuserid
RUN addgroup --gid $USERID {youruserID} \
   && adduser \
   --disabled-password \
   --gecos "" \
   --home "$(pwd)" \
   --ingroup {youruserID} \
   --no-create-home \
  # --force-badname\
   --uid $USERID \
   {youruserID}

# Install pygments (for syntax highlighting) 
RUN apt-get -qq update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -qq install -y --no-install-recommends apt-utils libstdc++6 python-pygments git ca-certificates asciidoc curl \
	&& rm -rf /var/lib/apt/lists/*

# Download and install hugo
ENV HUGO_VERSION 0.64.1 
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.deb
ENV SITE_DIR '/src'

RUN curl -sL -o /tmp/hugo.deb \
    https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb && \
    mkdir ${SITE_DIR}



WORKDIR ${SITE_DIR}
COPY ./ ${SITE_DIR}
# Expose default hugo port
EXPOSE 1313
# By default, serve site
ENV HUGO_APPEND_PORT true
ENV HUGO_BASE_URL https://example.com
# Automatically build site
ADD site/ ${SITE_DIR}
RUN hugo -d /var/www/nginx/html/


#ENV HUGO_THEME "hugo-theme-techdoc"

#ENTRYPOINT ["/bin/sh"]
CMD hugo server -D ${HUGO_BASE_URL} --bind=0.0.0.0
