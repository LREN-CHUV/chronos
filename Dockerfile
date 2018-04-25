# Build stage for Java classes
FROM hbpmip/java-base-build:3.5.2-jdk-8-0 as java-build-env

RUN apk --update --no-cache add nodejs-current

COPY pom.xml build.xml /project/
COPY src/ /project/src/

RUN cp /usr/share/maven/ref/settings-docker.xml /root/.m2/settings.xml \
    && mvn clean package

FROM mesosphere/mesos:1.5.0

ENV JAVA_OPTIONS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"

RUN \
    # Update repositories
    apt-get -y update && \
    # Install neat tools
    apt-get install -y ca-certificates-java openjdk-8-jre-headless && \
    # jdk setup
    /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    apt-get remove -y openjdk-9-jre-headless && \
    ln -svT "/usr/lib/jvm/java-8-openjdk-$(dpkg --print-architecture)" /docker-java-home && \
    update-java-alternatives --set java-1.8.0-openjdk-$(dpkg --print-architecture) && \
    # clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8080

ENV JAVA_HOME /docker-java-home

COPY --from=java-build-env /project/target/chronos.jar /chronos/chronos.jar
COPY bin/start.sh /chronos/bin/start.sh

ENTRYPOINT ["/chronos/bin/start.sh"]
