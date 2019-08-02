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

---
#### Lua变量
Lua变量有三种类型：**全局变量**、**局部变量**、**表中的域**。  

+ Lua中的变量全是全局变量，那怕是语句块或是函数里，除非用`local`显式声明为局部变量。  
+ 局部变量的作用域为从声明位置开始到所在语句块结束。
+ 变量的默认值均为`nil`。

---
#### 赋值语句
Lua可对多个变量同时赋值，变量列表和值列表的各个元素用逗号分开，赋值语句右边的值会依次赋给左边的变量。  
```
a, b = 10, 2*x   <-->  a=10;b=2*x
```
Lua会先计算赋值语句右边所有的值然后再执行赋值操作。  
```
x, y = y, x    -- 交换x和y
a[i], a[j] = a[j], a[i]   -- 交换a[i]和a[j]
```
当变量个数和值的个数不一致时，Lua会采取如下策略：  

+ 变量个数大于值的个数，按变量个数补足`nil`
+ 变量个数小于值的个数，多余的值会被忽略  

---
#### 索引
对table的索引使用方括号`[]`，同时也提供了`.`操作。  

---
#### 循环

+ `while`循环  

   ```lua
   while(condition)
   do
     statements
   end
   ```
+ `for`循环  

   ```lua
   -- 数值for循环
   for var=exp1,exp2,exp3 do  
       <执行体>  
   end  

   -- 泛型for循环
   a = {"one", "two", "three"}
   for i, v in ipairs(a) do
       print(i, v)
   end 
   ```
+ `repeat ... until`循环  
  
  ```lua
  repeat
    statements
  until(condition)
  ```
+ 循环嵌套  

可通过`break`语句退出当前循环或语句，并开始脚本执行紧接着的语句。  

---
#### 流程控制
通过`if`语句或`if...else`控制语句可选择的执行指定代码。  
控制结构的条件表达式结果可以是任何值，Lua认为false和nil是假，true和非nil为真。  
> 在Lua中0为true。

---
#### 函数
函数的定义格式：  

```lua
optional_function_scope function function_name( argument1, argument2, argument3..., argumentn)
    function_body
    return result_params_comma_separated
end
```

+ `optional_function_scope`：未设置该参数默认为全局函数，使用关键字local可变更为局部函数
+ `function_name`：指定函数名称
+ `argument1, argument2, argument3..., argumentn`：函数参数，可为空
+ `function_body`：函数体，函数中需要执行的代码语句块
+ `result_params_comma_separated`：函数返回值，可返回多个值，每个值以逗号隔开

#### 可变参数
Lua函数可接受可变数目的参数，在函数参数列表中使用三个点`...`标识函数值有可变的参数。  
可以通过`select('#', ...)`获取可变参数的数量；也可将可变参数赋值给一个变量，如`local arg = {...}`。  
当固定参数和可变参数共存时，固定参数必须放在可变参数之前。  

---
#### 运算符

+ 算术运算符  
  加法：`+` 减法：`-` 乘法：`*` 除法：`/` 取余：`%` 乘幂：`^` 负号：`-`
+ 关系运算符  
  等于：`=` 不等于：`~=` 大于：`>` 小于：`<` 大于等于：`>=` 小于等于：`<=`
+ 逻辑运算符  
  逻辑与：`and` 逻辑或：`or` 逻辑非：`not`
+ 其他运算符  
  - `..`：连接字符串
  - `#`：一元运算符，返回字符串或表的长度  

#### 运算符优先级
优先级从高到低的顺序：  
```lua
^
not -(一元运算符)
* /
+ -
..
< > <= >= ~= ==
and
or
```

---
#### 字符串
Lua中字符串可以使用以下三种方式标识：  

+ 单引号间的一串字符
+ 双引号间的一串字符
+ [[和]]间的一串字符  

#### 字符串操作

| 方法 | 用途 |
| :--: | :--: |
| `string.upper(arg)` | 字符串全部转为大写字母 |
| `string.lower(arg)` | 字符串全部转为小写字母 |
| `string.gsub(mainStr, findStr, replaceStr, num)` | 字符串替换，mainStr为要替换的字符串，findStr为被替换的字符，replaceStr为替换后的字符，num为替换次数 | 
| `string.find(str, substr, [init, [end]])` | 在指定的字符串中搜索指定内容（init-end为索引），返回其具体位置，不存在则返回nil。 |
| `string.reverse(arg)` | 字符串反转 |
| `string.format(...)` | 返回类似printf的格式化字符串 |
| `string.char(arg...)`和`stirng.byte(arg[,int])` | char将整型数字转成字符并连接，byte转换字符为整数型 |
| `string.len(arg)` | 计算字符串长度 |
| `string.rep(str, n)` | 返回字符串str的n个拷贝 |
| `string.gmatch(str, pattern)` | 返回一个迭代器函数，每一次调用返回一个在字符串str找到的下一个符合pattern描述的子串，如果没找到则返回nil。 |
| `string.match(str, pattern[, init])` | 只寻找源字符串str的第一个配对。 |


















