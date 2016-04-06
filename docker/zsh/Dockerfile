FROM jess/zsh

RUN apt-get update \
      && apt-get install -y git \
      && apt-get clean

ENTRYPOINT ["/usr/bin/zsh"]
