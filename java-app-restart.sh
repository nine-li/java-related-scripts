#!/bin/bash
# 这是一个用于重启Java应用的Linux Bash Shell脚本。
#
# 用法：
#   1. 将脚本文件和欲重启的Java应用放致同一目录；
#   2. 修改位于脚本开头处的MY_APP_NAME变量的值；
#   3. 修改位于脚本开头处的MY_APP_NAME_LOGS变量的值(可选)；
#   4. 为脚本文件添加可执行权限(若无)；
#   5. 执行脚本文件。
#
# 注意：
#   1. 该脚本依赖由Oracle实现的Open JDK/Oracle JDK中的jps命令行工具进行Java进程查找；
#
#   2. jps处于实验性阶段，若在未来版本中发生不兼容的改变，则该脚本可能无法正常工作。更多
#      信息见https://docs.oracle.com/en/java/javase/17/docs/specs/man/jps.html；
#
#   3. 使用其它厂商的JDK的用户请自测该脚本是否可用；

#   4. 若运行Java应用的JVM进程和脚本运行时采用jps命令行工具的JDK来自不同的厂商实现，则
#      运行的Java应用也许不可见。如您指定使用来自IBM/Eclipse的基于OpenJ9虚拟机的JDK运
#      行Java应用程序，但脚本运行时采用的时来自Oracle的基于Hotshot虚拟机的JDK，则运行
#      的Java应用或许对脚本不可见。

# 待重启的Java应用
MY_APP_NAME="example-1.2-SNAPSHOT.jar"
MY_APP_NAME_LOGS="$MY_APP_NAME.log"

# 获取Java应用列表
java_app_list=$(jps)

# IFS是一个内部变量，它决定Bash如何识别单词边界
# Note：该变量默认值即是空格，为防止改变了被其它脚本修改，这里显式重设为空格
IFS=' '

# 将换行符替换成空格
java_app_list="${java_app_list//$'\n'/ }"

# 将java_app_list字符串变量根据IFS(空格)切割成数组并保存到java_app_array变量
read -ra java_app_array <<<"$java_app_list"

# 获取数组长度
array_length=${#java_app_array[@]}

# 遍历数组
index=-1
for ((i = 0; i < ${array_length}; i++)); do
    # 获取数组元素(字符串)
    temp="${java_app_array[$i]}"
    # 判断是否temp字符串是否为待查找的字符串
    if [[ $temp == $MY_APP_NAME ]]; then
        # 将当前i的值赋值给index变量
        index=$i
    fi
done

# 判断Java应用进程是否找到
if [[ $index == -1 ]]; then
    echo "错误：找不到指定的Java应用进程，脚本已退出"
    exit 1
fi

# 获取待重启Java应用的标识符
app_identifier=${java_app_array[$(($index - 1))]}
echo "Java应用进程的标识符为$app_identifier"

# 杀死Java应用进程
kill -9 $app_identifier
echo "已终结Java应用进程"

# 清理日志文件(若存在)
if [ -f $MY_APP_NAME_LOGS ]; then
    rm $MY_APP_NAME_LOGS
    echo "日志文件已删除"
fi

# 后台启动Java应用进程
nohup java -jar $MY_APP_NAME >$MY_APP_NAME_LOGS 2>&1 &

echo "Java应用进程已启动"
exit 0