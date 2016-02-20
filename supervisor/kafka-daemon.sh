#!/bin/bash
/home/kafka/create-topics.sh >> /var/log/kafka-topics.log 2>&1 &
exec /sbin/setuser kafka java -Xmx512m -Xms512m -server \
-XX:+UseParNewGC  \
-XX:+UseConcMarkSweepGC \
-XX:+CMSClassUnloadingEnabled \
-XX:+CMSScavengeBeforeRemark \
-XX:+DisableExplicitGC \
-XX:+PrintGCDateStamps \
-XX:+PrintGCTimeStamps \
-XX:+PrintGCDetails \
-Djava.library.path=/usr/local/lib:/opt/local/lib:/usr/lib \
-Djava.net.preferIPv4Stack=true  \
-Djava.awt.headless=true \
-verbose:gc \
-Dkafka.logs.dir=/home/kafka/log \
-Dlog4j.configuration=file:$KAFKA_HOME/config/log4j.properties \
-Xloggc:/home/kafka/log/kafkaServer-gc.log \
-cp "$KAFKA_HOME/libs/*" \
kafka.Kafka $KAFKA_HOME/config/server.properties >> /var/log/kafka.log 2>&1