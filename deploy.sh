#!/bin/sh
# $1 = ${BUILD_ID}
# $2 = shutdown wait seconds
# $3 = startup wait seconds
# $4 = deploy path
# $5 = nostart debug or null
JAVA_OPTS="-server -Xms1024M -Xmx1024M -XX:+UseConcMarkSweepGC -XX:PretenureSizeThreshold=32m -XX:MaxMetaspaceSize=400m -XX:MetaspaceSize=256m -XX:+UseParNewGC -XX:ConcGCThreads=2 -XX:ParallelGCThreads=2 -XX:+CMSScavengeBeforeRemark -XX:+UseCMSCompactAtFullCollection -XX:MaxTenuringThreshold=10 -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=80 -XX:CMSMaxAbortablePrecleanTime=600 -XX:+CMSParallelRemarkEnabled -XX:+ParallelRefProcEnabled -verbose:gc -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime"

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.262.b10-0.el7_8.x86_64
export CLASSPATH=${JAVA_HOME}/lib:.
export PATH=${JAVA_HOME}/bin:$PATH
#打包后的执行文件名
PRO_NAME=$6

#构建后保存jar文件位置
TARGET_HOME=$4/target

#项目部署目录
DEPLOY_PATH=$4

#
# BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DATE=`date +%Y%m%d%H%M%S`

echo $PRO_NAME
if [ "$PRO_NAME" = "" ]; then
    echo "ERROR:jar文件输入出错!"
    exit 0

fi
#kill tomcat 进程
if [ -z "$5" -o "$5" != "nostart" ]; then
        PID_FILE=$DEPLOY_PATH/java-project.pid
    if [ -f $PID_FILE ]; then
                PID=`cat $PID_FILE`
        fi
        EXIST_PID=`ps -ax|awk '{print $1}'|grep "^$PID$"`
        echo  $1, 'exist_pid' = $EXIST_PID
        if [ -z $EXIST_PID ]; then 
                PORT_NUM=`cat $DEPLOY_PATH/port_num`
                echo 'port_num' $PORT_NUM
                PID=`lsof -i:$PORT_NUM |awk '{print $2}' | tail -n 1`
        fi
        echo === `ps awx | awk '$1 == $PID { print $7 }'`
        if [ -n $PID ]; then
                echo kill $PID
                kill $PID
                sleep $2
                kill -0 $PID
                return_code=$?
                if [ $return_code -eq 0 ]; then
                        echo kill -9 $PID
                        kill -9 $PID
                fi
        fi
fi

# ps -ef |grep "$PRO_NAME" | awk '{print "kill -9 " $2}' | sh

#备份原始jar文件
if [ ! -d "$DEPLOY_PATH/bak" ]; then
    mkdir $DEPLOY_PATH/bak
fi

if [ -e $DEPLOY_PATH/$PRO_NAME ]; then
        echo bakcup $DEPLOY_PATH/$PRO_NAME to $DEPLOY_PATH/bak
        cp $DEPLOY_PATH/$PRO_NAME $DEPLOY_PATH/bak/$PRO_NAME-$DATE.jar
fi

echo move target file: $TARGET_HOMEE/$PRO_NAME to deploy home :$DEPLOY_PATH
cd $DEPLOY_PATH
mv $TARGET_HOME/$PRO_NAME $DEPLOY_PATH/$PRO_NAME

if [ -z "$5" -o "$5" != "nostart" ] ;then
        echo begin start $DEPLOY_PATH/$PRO_NAME
        exec nohup java -Dzugeliang.home=$DEPLOY_PATH $JAVA_OPTS -jar $PRO_NAME >> /dev/null 2>&1 &
        sleep $3
        tail -n 100 logs/java-project.log
fi
if [ ! -f $PID_FILE ]; then
        touch "$PID_FILE"
fi
echo $! > $PID_FILE

echo deploy at $DATE >> $DEPLOY_PATH/deploy.log
exit 
