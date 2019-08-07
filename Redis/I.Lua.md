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
  等于：`==` 不等于：`~=` 大于：`>` 小于：`<` 大于等于：`>=` 小于等于：`<=`
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

---
#### Lua数组
数组是相同数据类型的元素按一定顺序排列的集合，可以是一维数组和多维数组。通过`a = {}`声明。  
多维数组即数组中包含数组或一维数组的索引键对应一个数组。  

---
### 迭代器
迭代器是一种对象，能够用来遍历**标准模板库容器**中的部分或全部元素，每个迭代器代表容器中的确定的地址。   
#### 泛型for迭代器
泛型for在自己内部保存迭代函数，实际上保存三个值：**迭代函数**、**状态常量**、**控制变量**。  
泛型for迭代器提供了集合的key/value对，语法格式如下：  
```lua
for k,v in pairs(t) do
  print(k,v)
end
```

在Lua中常常使用函数来描述迭代器，每次调用该函数返回集合的下一个元素。Lua的迭代器包含以下两个类型：  
+ **无状态的迭代器**
+ **多状态的迭代器**

#### 无状态的迭代器
无状态的迭代器是指不保留任何状态的迭代器，在循环中可避免创建闭包花费额外的代价。  
每一次迭代，迭代函数都是用两个变量（状态常量和控制变量）的值作为参数被调用。一个无状态的迭代器只利用这两个值可以获取下一个元素，比如ipairs函数。

#### 多状态的迭代器
迭代器需要保存多个状态信息而不是简单的状态常量和控制变量时，可通过闭包或把所有的状态信息封装到table内。  

```lua
array = {"Google", "Runoob"}

function elementIterator (collection)
   local index = 0
   local count = #collection
   -- 闭包函数
   return function ()
      index = index + 1
      if index <= count
      then
         --  返回迭代器的当前元素
         return collection[index]
      end
   end
end

for element in elementIterator(array)
do
   print(element)
end
```

---
# Lua表
table是Lua的一种数据结构，可以用来创建不同的数据类型，如：数组、字典等。
+ 使用关联型数组，可以用任意类型的值类作数组的索引，但不可以是nil。  
+ 不固定大小的，可以根据需要进行扩容。  
+ Lua可以通过table来解决模块(module)、包(package)和对象(Object)。  

| 方法 | 描述 |
| :--: | :--: |
| `table.concat(table[, sep [, start [, end]]])` | 列出参数中指定table的数组部分从start位置到end位置的所有元素，元素间以指定的分隔符(sep)隔开。 |
| `table.insert(table, [pos,] value)` | 在table的数组部分指定位置pos插入值未value的一个元素。pos可选，默认为数组部分的末尾。 |
| `table.remove(table [, pos])` | 返回table数组部分位于pos位置的元素，其后的元素会被前移。pos可选，默认从最后一个元素删除。 |
| `table.sort(table [, comp])` | 对给定的table进行升序排序。 | 


---
# Lua模块与包

### 模块
模块类似于封装库，可以把一些公用的代码放在一个文件中，以API接口的形式在其他地方调用，有利于代码的重用和降低代码耦合度。  

Lua的模块是由变量、函数等已知元素组成的table，文件代码格式如下：  

```lua
-- 文件名为 module.lua
-- 定义一个名为 module 的模块
module = {}
 
-- 定义一个常量
module.constant = "这是一个常量"
 
-- 定义一个函数
function module.func1()
    io.write("这是一个公有函数！\n")
end
 
local function func2()
    print("这是一个私有函数！")
end
 
function module.func3()
    func2()
end
 
return module
```

### require函数
Lua通过require函数加载模块：
```lua
-- 方式一
require("<模块名称>")
-- 方式二
require "<模块名称>"
-- 别名
local m = require("<模块名称>")
```

### 加载机制
`require`用于搜索Lua文件的路径存放在全局变量`package.path`中，当Lua启动后，以环境变量`LUA_PATH`的值来初始化该变量。如果找到目标文件，则调用`package.loadfile`来加载模块。  
如果未找到，则会查找C程序库，搜索的文件路径是从全局变量`package.cpath`获取，变量通过环境变量`LUA_CPATH`初始化，如果找到则通过`package.loadlib`来加载。  

### Lua元表(Metatable)
**元表**：对table操作进行扩展的表，元表里面填的是元方法。可通过`setmetatable(mytable,mymetatable)`函数操作把表和元表进行绑定，这样表(mytable)就有了你自定义的功能。

+ `setmetatable(table, metatable)`：对指定table设置元表(metatable)，如果元表(metatable)中存在`__metatable`键值，setmetatable会失败。
+ `getmetatable(table)`：返回对象的元表(metatable)。  

#### __index元方法
__index则用来对表访问  

+ 当通过键访问table的时候，如果键没有对应的值，Lua会寻找table的metatable中的__index键。
+ 如果__index包含一个表格，Lua会在表格中查找相应的键。  
+ 如果__index包含一个函数的话，Lua会调用函数，table和键作为参数传递给函数。  

#### __newindex元方法
__newindex 元方法用来对表更新  

+ 对表进行赋值，如果索引存在，则执行赋值操作
+ 如果索引不存在，则查找__newindex元方法并调用

#### 操作符

| 模式 | 描述 |
| :-- | :--: |
| `__add` | 对应`+` |
| `__sub` | 对应`-` |
| `__mul` | 对应`*` |
| `__div` | 对应`/` |
| `__mod` | 对应`%` |
| `__unm` | 对应`-` |
| `__concat` | 对应`..` |
| `__eq` | 对应`==` |
| `__lt` | 对应`<` |
| `__le` | 对应`<=` |

#### __call元方法
将table作为函数使用，并传递参数及返回自定义结果。  
```lua
mytable = {"C#","PHP","Java","Python"}

mymetatable = {
--第一个参数是mytable表,其他的是函数的参数,参数可以是表
__call = function(tab,arg1,arg2)
  print(arg1.." - " ..arg2)
  return arg1*arg2,arg1/arg2
end

}
--设置元表
mytable = setmetatable(mytable,mymetatable)

a , b = mytable(10,5) -- 10 - 5 
print(a) -- 50
print(b) -- 2
```

#### __tostring元方法
用于修改表的输出行为。  

---
# Lua协同程序(coroutine)
Lua协同类似于线程：拥有独立的堆栈，独立的局部变量，独立的指令指针，可与其他协程共享全局变量和其他大部分东西。  

在任一指定时刻只有一个协程在运行，并且这个正在运行的协程只有在明确的被要求挂起的时候才会被挂起。（类似同步的多线程）  

| 方法 | 描述 |
| :--: | :--: |
| `coroutine.create()` | 创建coroutine，返回coroutine，参数是一个函数，当和resume配合使用时唤醒函数调用 |
| `coroutine.resume()` | 重启coroutine，和create配合使用 |
| `coroutine.yield()` | 挂起coroutine，将coroutine设置为挂起状态 |
| `coroutine.status()` | 查看coroutine状态，状态有三种：dead、suspended、running |
| `coroutine.wrap()` | 创建coroutine，返回一个函数，调用该函数就进入coroutine |
| `coroutine.running()` | 返回正在运行的coroutine的线程号 |


---
# Lua文件I/O
Lua I/O库用于读取和处理文件，分为简单模式、完全模式：  
+ **简单模式**：拥有一个当前输入文件和一个当前输出文件，并且提供针对这些文件相关的操作。  
+ **完全模式**：使用外部的文件句柄来实现，以一种面向对象的形式，将所有的文件操作定义为文件句柄的方法。  

```lua
file = io.open(filename [, mode])  -- 打开文件
```
mode的值：

| 模式 | 描述 |
| :--: | :--: |
| `r` | 以只读方式打开文件，文件必须存在。 |
| `w` | 打开只写文件，文件存在则文件长度清零，内容消失。文件不存在则建立文件。 |
| `a` | 以附加的方式打开只写文件。文件不存在则创建；文件存在则保留原内容并追加到文件尾。 |
| `r+` | 以可读写的方式打开文件，文件必须存在。 |
| `w+` | 打开可读写文件，若文件存在则文件长度清零，文件内容消失。文件不存在则建立该文件。 |
| `a+` | 与a类似，但文件可读可写。 |
| `b` | 二进制模式，如果文件是二进制文件可以使用b。 |
| `+` | 表示对文件可读可写。 |

### 简单模式
简单模式使用标准的I/O使用一个当前输入文件和一个当前输出文件。
```lua
-- 以只读方式打开文件
file = io.open("test.lua", "r")

-- 设置默认输入文件为 test.lua
io.input(file)

-- 输出文件第一行
print(io.read())

-- 关闭打开的文件
io.close(file)

-- 以附加的方式打开只写文件
file = io.open("test.lua", "a")

-- 设置默认输出文件为 test.lua
io.output(file)

-- 在文件最后一行添加 Lua 注释
io.write("--  test.lua 文件末尾注释")

-- 关闭打开的文件
io.close(file)
```

### 完全模式
当需要在同一时间处理多个文件时，使用filename:function_name代替io.function_name方法：  
```lua
-- 以只读方式打开文件
file = io.open("test.lua", "r")

-- 输出文件第一行
print(file:read())

-- 关闭打开的文件
file:close()

-- 以附加的方式打开只写文件
file = io.open("test.lua", "a")

-- 在文件最后一行添加 Lua 注释
file:write("--test")

-- 关闭打开的文件
file:close()
```

---
# Lua错误处理
Lua中可使用两个函数：`asset`和`error`来处理错误。
```lua
-- 检查第一个参数，存在问题则把第二个参数作为错误信息抛出
assert(type(a) == "number", "a不是一个数字")
-- 终止正在执行的函数，并返回message的内容作为错误信息
error(message [, level])
```

Lua中处理错误，可以使用函数`pcall(protected call, ...)`来包装需要执行的代码。pcall接收一个函数和要传递给后者的参数，并执行，执行结果：有错误、无错误哦，返回值为true、false或errorinfo。  
```lua  
if pcall(function_name, ….) then
-- 没有错误
else
-- 一些错误
end
```

`xpcall(protected call, error handler, ..)`函数接收的第二个参数是一个错误处理函数，错误发生时Lua在调用栈展开前调用错误处理函数。  
+ `debug.debug`  
  提供一个Lua提示符，供用户来检查错误的原因。  
+ `debug.traceback`  
  根据调用栈来构建一个扩展的错误信息。

---
# 垃圾回收
Lua采用了自动内存管理，意味着开发者不用管理新创建对象的内存分配，以及对象不再被使用后释放内存的问题。  
Lua运行了一个**垃圾收集器**来收集所有*死对象*（即在Lua中不可再访问到的对象）来完成自动内存管理的工作。  
Lua的垃圾收集器实现为**增量标记-扫描收集器**，通过**垃圾收集器间歇率**和**垃圾收集器步进倍率**来控制垃圾收集循环，单位都是百分数。  

垃圾回收器函数  
| 函数 | 描述 |
| :--: | :--: |
| `collectgarbage("collect")` | 做一次完整的垃圾收集循环，通过参数opt提供了一组不同的功能。 |
| `collectgarbage("count")` | 以K字节数为单位返回Lua使用的总内存数，存在小数部分。 |
| `collectgarbage("restart")` | 重启垃圾收集器的自动运行。 |
| `collectgarbage("setpause")` | 将arg设为收集器的间歇率，返回间歇率的前一个值。 |
| `collectgarbage("setstepmul")` | 返回步进倍率的前一个值。 |
| `collectgarbage("step")` | 单步运行垃圾收集器，步长大小由arg控制。 |
| `collectgarbage("stop")` | |

---
# Lua面向对象

## 面向对象特征
+ **封装**  
  指能够把一个实体的信息、功能、响应都装入一个单独的对象中的特性
+ **继承**  
  继承的方法允许在不改动原程序的基础上对其进行扩充，这样使得原功能得以保存，而新功能也得以扩展。这有利于减少重复编码，提高软件的开发效率。  
+ **多态**  
  同一操作作用于不同的对象，可以有不同的解释，产生不同的执行结果。在运行时，可以通过指向基类的指针，来调用实现派生类中的方法。
+ **抽象**  
  抽象(Abstraction)是简化复杂的现实问题的途径，它可以为具体问题找到最恰当的类定义，并且可以在最恰当的继承级别解释问题。  

## Lua中面向对象
对象由属性和方法组成。Lua中用`table`来描述对象的属性，`function`可以用来表示方法。Lua中的类通过table+function模拟。  

```lua
-- 元类
Rectangle = {area = 0, length = 0, breadth = 0}

-- 派生类的方法 new
function Rectangle:new(o,length,breadth)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.length = length or 0
  self.breadth = breadth or 0
  self.area = length*breadth;
  return o
end

-- 派生类的方法 printArea
function Rectangle:printArea()
  print("矩形面积为 ",self.area)
end
```
 #### 创建对象  
```lua
r = Rectangle:new(nil, 10, 20)
```

#### 访问属性
```lua
print(r.length)
```
#### 访问成员函数
```lua
r:printArea()
```

## Lua继承
继承是指一个对象直接使用另一个对象的属性和方法，可用于扩展基础类的属性和方法。  

```lua
-- Meta class
Shape = {area = 0}
-- 基础类方法 new
function Shape:new(o,side)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  side = side or 0
  self.area = side*side;
  return o
end
-- 基础类方法 printArea
function Shape:printArea()
  print("面积为 ",self.area)
end

-- Square继承了Shape类
Square = Shape:new()
-- Derived class method new
function Square:new(o,side)
  o = o or Shape:new(o,side)
  setmetatable(o, self)
  self.__index = self
  return o
end
```


























