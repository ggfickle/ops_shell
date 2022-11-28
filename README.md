# ops_shell
linux Git项目发布shell脚本

非.sh结尾的文件`ln -s`链接至`/usr/bin`目录下，当作命令执行即可


## deploy.sh 脚本使用
java-project.pid content example: 29302

jenkins command example:  /home/admin/java-project/deploy.sh ${BUILD_ID} 5 20 /home/admin/java-project start java-project-1.0.0.jar
