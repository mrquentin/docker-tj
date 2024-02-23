ARG PROJECT_ID="422473"
ARG PROJECT_VERSION="1.3"
ARG CURSE_TOKEN

FROM alpine:latest as builder

ENV PROJECT_ID=$PROJECT_ID
ENV PROJECT_VERSION=$PROJECT_VERSION
ENV CURSE_TOKEN=$CURSE_TOKEN

RUN apt-get update && apt-get install -y curl unzip jq

WORKDIR /build

COPY prepare.sh .

RUN chmod +x ./prepare.sh
RUN ./prepare.sh

FROM openjdk:8-buster

LABEL version=$PROJECT_VERSION

RUN apt-get update && apt-get install -y curl unzip jq coreutils && \
 adduser --uid 99 --gid 100 --home /data --disabled-password minecraft

COPY --from=builder /pack-info.json .
COPY launch.sh /launch.sh
RUN chmod +x /launch.sh

USER minecraft

ENV PROJECT_VERSION=$PROJECT_VERSION

VOLUME /data
WORKDIR /data

EXPOSE 25565/tcp

CMD ["/launch.sh"]