# Lua学习

## Mac Os X系统安装
```bash
curl -R -O http://www.lua.org/ftp/lua-5.3.0.tar.gz
tar zxf lua-5.3.0.tar.gz
cd lua-5.3.0
make macosx test
make install
```

## 基本语法

#### 编程方式  
  + 交互式编程  
    通过命令行`lua -i`或`lua`来启动 
  + 脚本式编程  
    将lua程序代码保存在以`lua`结尾的文件并执行  

---
#### 注释  
  + 单行注释 
  
     ```

     --
     ```
  + 多行注释  

     ```
     --[[
      多行注释
      多行注释
     ]]--
     ```

---
#### 标识符  
标识符以一个字母A到Z或a到z或下划线`_`开头后加上0个或多个字母、下划线、数字(0到9)。   

---
#### 关键词  

| | | | | |
|---|---|--|---|--|
| and | break | do | else | elseif |
| end | false | for | function | if |
| in | local | nil | not | or |
| repeat | return | then | true | until |
| while | 

---
#### 全局变量
+ 在默认情况下，变量总是认为是全局的
+ 全局变量不需要声明，给一个变量赋值后即创建了这个全局变量
+ 删除一个全局变量，只需要将变量赋值为`nil`



