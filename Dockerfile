FROM openjdk:8-buster

ARG PROJECT_VERSION="1.3"

LABEL version=$PROJECT_VERSION

RUN apt-get update && apt-get install -y curl unzip jq && \
 adduser --uid 99 --gid 100 --home /data --disabled-password minecraft

COPY launch.sh /launch.sh
COPY pack-info.json /pack-info.json
COPY user_jvm_args.txt /data/user_jvm_args.txt
RUN chmod +x /launch.sh

USER minecraft

ENV PROJECT_VERSION=$PROJECT_VERSION

VOLUME /data
WORKDIR /data

EXPOSE 25565/tcp

CMD ["/launch.sh"]