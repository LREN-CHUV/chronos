# Build stage for Java classes
FROM hbpmip/java-base-build:3.5.2-jdk-8-0 as java-build-env

RUN apk --update --no-cache add nodejs-current

COPY pom.xml build.xml /project/
COPY src/ /project/src/

RUN cp /usr/share/maven/ref/settings-docker.xml /root/.m2/settings.xml \
    && mvn clean package

FROM hbpmip/java-base:8u151-2
ARG http_proxy
ENV http_proxy ${http_proxy}

RUN apt-get update \
    && apt-get install -y gnupg \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF \
    && echo "deb http://repos.mesosphere.com/debian jessie-unstable main" | tee /etc/apt/sources.list.d/mesosphere.list \
    && echo "deb http://repos.mesosphere.com/debian jessie-testing main" | tee -a /etc/apt/sources.list.d/mesosphere.list \
    && echo "deb http://repos.mesosphere.com/debian jessie main" | tee -a /etc/apt/sources.list.d/mesosphere.list \
    && apt-get update \
    && apt-get install -y systemd \
    && apt-get install --no-install-recommends -y --allow-remove-essential mesos=1.5.0-2.0.1 \
    && apt-get remove -y systemd \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=java-build-env /project/target/chronos.jar /chronos/chronos.jar
COPY bin/start.sh /chronos/bin/start.sh

ENTRYPOINT ["/chronos/bin/start.sh"]
