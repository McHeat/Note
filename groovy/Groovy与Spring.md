# Groovy与Spring集成

## 一、 依赖jar
在项目中引入groovy依赖：  
```xml
  <dependency>
    <groupId>org.codehaus.groovy</groupId>
    <artifactId>groovy-all</artifactId>
    <version>x.y.z</version>
  </dependency>
```

## 二、Groovy实现原理
groovy负责词法、语法解析groovy文件，然后通过ASM生成普通的java字节码文件供jvm使用。  

> ASM是一个Java字节码操控框架。它能被用来动态生成类或者增强既有类的功能。ASM 可以直接产生二进制class文件，也可以在类被加载入Java虚拟机之前动态改变类行为。

Groovy是基于JVM的语言，与Java可以方便的进行互操作。但groovy文件依然会编译成class文件后才可以运行：  
+ 没有类定义的脚本  
  脚本中只有执行代码没有定义任何类，会编译生成以文件名为类名的`Script`子类，并利用执行代码实现抽象方法`run()`。同时还会生成一个main方法，作为整个脚本的入口。
+ 仅有一个类的脚本  
  如果Groovy脚本文件里仅含有一个类，且名字和脚本文件名字一致时，会生成与所定义的类一致的class文件，Groovy类都会实现`groovy.lang.GroovyObject`接口。
+ 多个类的脚本  
  如果Groovy脚本文件含有一个或多个类，groovy编译器会为每个类生成一个对应的class文件。如果想直接执行这个脚本，则脚本里的**第一个类**必须有一个`static`的main方法。
+ 执行代码&类定义的脚本  
  如果Groovy脚本文件有执行代码且有定义类, 那么所定义的类会生成对应的class文件，脚本本身也会被编译成一个Script的子类，类名和脚本文件的文件名一样。  

## 三、 与Java集成方式
Groovy调用Java的方式，包括：  
+ `GroovyClassLoader`  
  定制的类加载器，可加载Java中使用到的Groovy类。  
```java
GroovyClassLoader loader = new GroovyClassLoader();
Class groovyClass = loader.parseClass(new File(groovyFileName));
GroovyObject groovyObject = (GroovyObject) groovyClass.newInstance();
groovyObject.invokeMethod("run", "helloworld");
```
+ `GroovyShell`  
  在Java类中执行Groovy表达式来求值，可输入值并通过GroovyShell返回Groovy表达式的计算结果。  
```java
  GroovyShell shell = new GroovyShell();
  Script groovyScript = shell.parse(new File(groovyFileName));
  Object[] args = {};
  groovyScript.invokeMethod("run", args);
```
+ `GroovyScriptEngine`
  `GroovyScriptEngine`可从指定位置加载Groovy脚本，并随着脚本变化而重新加载。  

## 四、与Spring集成
Spring对动态语言的支持位于`org.springframework.scripting`包下，通过`ScriptFactory`和`ScriptSource`接口支持动态语言集成到基于Spring的应用程序中，以`Groovy`、`JRuby`或任何受支持的语言编写的应用程序部分可以无缝地集成到Spring应用程序中。  

+ `ScriptSource`: 用于定位脚本来源的接口，并跟踪脚本是否被更改。
+ `ScriptFactory`: 脚本定义接口，封装了特定脚本的配置和用于创建实际脚本化Java对象的工厂方法。
+ `ScriptEvaluator`: Spring中用于执行脚本的策略的接口。  
+ `ScriptFactoryPostProcessor`: 用于处理`ScriptFactory`定义的`BeanPostProcessor`，将每个工厂替换为实际脚本化java对象。  

















