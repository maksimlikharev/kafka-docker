# use the ubuntu base image provided by dotCloud
FROM phusion/baseimage:0.9.18

# Install Oracle JDK 8 and others useful packages
RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y software-properties-common && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
apt-get install -y oracle-java8-installer && \
rm -rf /var/cache/oracle-jdk8-installer && \
rm -rf /usr/lib/jvm/java-8-oracle/bin && \
rm -rf /usr/lib/jvm/java-8-oracle/include && \
rm -rf /usr/lib/jvm/java-8-oracle/man && \
rm -rf /usr/lib/jvm/java-8-oracle/db && \
rm -rf /usr/lib/jvm/java-8-oracle/lib && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/service/* && \
find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true && \
find /usr/share/doc -empty|xargs rmdir || true && \
rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/* && \
rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*

ENV KAFKA_VERSION 0.8.2.2
ENV SCALA_VERSION 2.10

ENV KAFKA_HOME /usr/share/kafka

RUN groupadd kafka; useradd --gid kafka --home-dir /home/kafka --create-home --shell /bin/bash kafka

# Download and Install Apache Kafka
RUN wget http://apache.mirrors.ovh.net/ftp.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && \
tar -xzvf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz -C /usr/share && mv /usr/share/kafka_$SCALA_VERSION-$KAFKA_VERSION $KAFKA_HOME && \
rm -rf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && \
mkdir -p /var/log/kafka /kafka && chown -R kafka:kafka /var/log/kafka && ln -s /var/log/kafka /home/kafka/log && mkdir -p /etc/my_init.d && \
chown -R kafka:kafka /home/kafka /kafka && \
mkdir -p /etc/service/kafka

# Add VOLUMEs to allow backup of config and logs
VOLUME ["/usr/share/kafka/config","/var/log/kafka","/kafka"]

ADD script/kafka-env.sh /etc/my_init.d/kafka-env.sh
ADD supervisor/kafka-daemon.sh /home/kafka/kafka-daemon.sh

ADD script/broker-list.sh /home/kafka/broker-list.sh
ADD script/create-topics.sh /home/kafka/create-topics.sh
ADD script/start-kafka-shell.sh /home/kafka/start-kafka-shell.sh

RUN chown -R kafka:kafka $KAFKA_HOME && \
chmod a+x /etc/my_init.d/kafka-env.sh && \
chmod a+x /home/kafka/kafka-daemon.sh && \
ln -s /home/kafka/kafka-daemon.sh /etc/service/kafka/run

CMD ["/sbin/my_init"]
