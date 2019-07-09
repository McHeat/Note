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

---
#### 数据类型

| 数据类型 | 描述 |
|--|--|
| `nil` | 这个最简单，只有值nil属于该类，表示一个无效值（在条件表达式中相当于false）。 |
| `boolean` | 包含两个值：false和true。 |
| `number` | 表示双精度类型的实浮点数 |
| `string` | 字符串由一对双引号或单引号来表示 |
| `function` | 由 C 或 Lua 编写的函数 |
| `userdata` | 表示任意存储在变量中的C数据结构 |
| `thread` | 表示执行的独立线路，用于执行协同程序 |
| `table` | Lua 中的表（table）其实是一个"关联数组"（associative arrays），数组的索引可以是数字、字符串或表类型。在Lua里，table的创建是通过"构造表达式"来完成，最简单构造表达式是{}，用来创建一个空表。 |
















