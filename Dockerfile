FROM manimcommunity/manim:latest

USER root
RUN mkdir -p /github/workspace && chmod -R 777 /github/workspace

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
