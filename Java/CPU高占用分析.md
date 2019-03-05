# CPU 高占用分析
1. jps命令获取Java进程的PID
2. 使用`jstack`导出CPU占用高进程的线程栈  
`jtack PID >> dump.txt`
3. 使用top查看对应进程的哪个线程占用CPU过高  
`top -H -p PID`
4. 将线程的PID转换为16进制，大写转换为小写   
`echo "obase=16;PID" | bc`
5. 通过16进制的线程PID在步骤2中导出的线程栈文件中查找线程栈信息
6. 分析负载高的线程栈的业务操作，优化程序并处理问题  
