#!/bin/bash
OPERATE=$1
APP_NAME=$2

RUNNING="false";

# 检查应用是否在运行
function check() {
	echo "check running status..."
	tpid=`ps -ef|grep -n " java.*--name=$APP_NAME$"|grep -v grep|grep -v kill|awk '{print $2}'`
	if [ ${tpid} ]; then
    	echo 'App is running.'
    	RUNNING="true"
	else
	    echo 'App is NOT running.'
	    RUNNING="false"
	fi
}

# 启动程序
function start() {
	filePah=${APP_NAME}
	# 处理相对路径
	if [ ${filePah:0:1} != "/" ]; then
		filePah="`pwd`/${filePah}"
	fi
	# 用文件名作为 APP_NAME
	APP_NAME=${filePah##*/}
	APP_NAME=${APP_NAME%%.*}

	# 检查是否已经存在
	check
	if [ ${RUNNING} == "true" ]; then
		echo "App already running!"
	else
		echo "start..."
		`nohup java -jar ${filePah} --name=${APP_NAME} > /tmp/${APP_NAME}Nohup.log 2>&1 &`
		check
		echo "Start success!"
	fi
}

# 停止程序
function stop() {
	tpid=`ps -ef|grep -n " java.*--name=$APP_NAME$"|grep -v grep|grep -v kill|awk '{print $2}'`
	if [ ${tpid} ]; then
	    echo 'Stop Process...'
	    kill -15 ${tpid}
	    # 检查程序是否停止成功
	    for ((i=0; i<10; ++i))  
		do  
			sleep 1
			tpid=`ps -ef|grep -n " java.*--name=$APP_NAME$"|grep -v grep|grep -v kill|awk '{print $2}'`
			if [ ${tpid} ]; then
				echo -e ".\c"
			else
				echo 'Stop Success!'
				break;
			fi
		done
		# 强制杀死进程
		tpid=`ps -ef|grep -n " java.*--name=$APP_NAME$"|grep -v grep|grep -v kill|awk '{print $2}'`
		if [ ${tpid} ]; then
		    echo 'Kill Process!'
		    kill -9 ${tpid}
		fi
	else
		echo 'App already stop!'
	fi
}

function list () {
	if [ ${APP_NAME} == "all" ]; then
		echo `ps -ef | grep -n "java.*--name="|grep -v grep|grep -v kill|awk '{printf $2"\t"$8"\t"} {split($11,b,"=");print b[2]}' `
	else
		echo `ps -ef | grep -n "java.*--name=${APP_NAME}$"|grep -v grep|grep -v kill|awk '{printf $2"\t"$8"\t"} {split($11,b,"=");print b[2]}' `
	fi
}

# 参数检查
if [ -z ${OPERATE} ] || [ -z ${APP_NAME} ];then
	if [ -z ${OPERATE} ];
		then
			echo "OPERATE can not be null."
		else
			echo "APP_NAME can not be null."
	fi
else
	# 启动程序
	if [ ${OPERATE} == "start" ]; then
		start
	# 停止程序
	elif [ ${OPERATE} == "stop" ]; then
		stop
	# 检查查询运行状态
	elif [ ${OPERATE} == "check" ]; then
		check
	# 查询所有项目
	elif [ ${OPERATE} == "list" ]; then
		list
	else
		echo "Not supported the OPERATE."
	fi
fi