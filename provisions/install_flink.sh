#!/usr/bin/env bash

# download flink
wget --quiet  http://apache.claz.org/flink/flink-1.0.3/flink-1.0.3-bin-hadoop27-scala_2.11.tgz


export FLINK_HOME=/opt/flink/
export FLINK=$FLINK_HOME/bin
export FLINK_CONFIG=$FLINK_HOME/conf


#write to environment file for all future sessions
sudo /bin/sh -c 'echo export FLINK_HOME="/opt/flink/" >> /etc/environment'
sudo /bin/sh -c 'echo export FLINK="$FLINK_HOME/bin" >> /etc/environment'
sudo /bin/sh -c 'echo export FLINK_CONFIG="$FLINK_HOME/conf" >> /etc/environment'


#sudo mkdir /opt/flink
sudo mkdir $FLINK_HOME

sudo  tar -zxvf flink-1.0.3-bin-hadoop27-scala_2.11.tgz  --strip-components 1  -C $FLINK_HOME

####################################################
############# config settings
####################################################

# declare task managers aka.  slave nodes 
# the slaves will be on same physical box 

echo 'localhost
localhost' > $FLINK_CONFIG/slaves


# set flink-conf.yaml

## set log directory 
export TARGET_KEY=taskmanager.tmp.dirs
export REPLACEMENT_VALUE=" \\/tmp\\/flink-temp"

sudo sed -c -i "s/# \($TARGET_KEY*\:*\).*/\1$REPLACEMENT_VALUE/" $FLINK_CONFIG/flink-conf.yaml 


## set tasks slots per slave/taskmanager 
export TARGET_KEY=taskmanager.numberOfTaskSlots
export REPLACEMENT_VALUE=" 3"

sudo sed -c -i "s/\($TARGET_KEY*\:*\).*/\1$REPLACEMENT_VALUE/" $FLINK_CONFIG/flink-conf.yaml 

# fs.hdfs.hadoopconf
# recovery.zookeeper.quorum

####################################################
######## start flink daemon
####################################################

# create log directory 
# give permission to logger's log directory 
# TODO : see if this can be changed to a different location 

# mkdir /opt/flink/log
sudo chown vagrant:vagrant /opt/flink/log/
sudo chmod -R 755 /opt/flink/log/

# create output directory
sudo mkdir -p /data/flink_output
sudo chown vagrant:vagrant /data/flink_output/
sudo chmod 755 -R /data/flink_output


# create temp directory 
mkdir /tmp/flink-temp
sudo chown vagrant:vagrant /tmp/flink-temp




####################################################
######## start flink daemon
####################################################

# sudo $FLINK/start-local.sh
sudo $FLINK/start-cluster.sh


####################################################
############# example 
####################################################

#sudo /opt/flink/bin/flink  run  /opt/flink/examples/streaming/Kafka.jar   --topic my-topic3  --bootstrap.servers 192.168.150.80:9092   --group.id  abc   --zookeeper.connect  192.168.150.70:2181
#tail -f /opt/flink/log//flink-*-jobmanager-*.out

#  /opt/flink/bin/flink run  /opt/flink/examples/batch/WordCount.jar





####################################################
#### Restrict Java heap space to avoid overflowing limited free RAM 
#### Else not all broker will get initialized 
####################################################

#write to environment file for all future sessions 
#sudo /bin/sh -c 'echo export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M" >> /etc/environment'

#export for the current session before starting kafka cluster 
#export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"


