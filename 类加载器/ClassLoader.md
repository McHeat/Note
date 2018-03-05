# 类加载器

ClassLoader（类加载器）负责将Class加载到JVM中，主要功能：
+ 将Class加载到JVM中
+ 审查每个类应该由谁加载，使用父优先的等级加载机制
+ 将Class字节码重新解析成JVM统一要求的对象格式

## 一、类结构分析

 使用或扩展ClassLoader主要会用到的方法：
 ![ClassLoader类主要结构信息](https://raw.githubusercontent.com/McHeat/Note/master/img/classloader/ClassLoader01.JPG)
 
 + ***defineClass*** \
   将byte字节流解析成JVM能够识别的CLass对象
 + ***findClass*** \
   实现类的加载规则，从而取得要加载类的字节码
 + ***resolveClass*** \
   使类被加载到JVM中时被链接(Link)
 + ***loadClass*** \
   在运行时加载指定的一个类
   
 ClassLoader是一个抽象类，实现自定义ClassLoader一般都会继承**URLClassLoader**子类，因为这个子类已实现了大部分功能。
 ClassLoader还提供了一些辅助方法，如获取class文件的方法***getResource***、***getResourceAsStream***等，还有获取SystemClassLoader的方法等。
 
## 二、等级加载机制


 ClassLoader使用的接待机制为**上级委托接待机制**。
 会员到达任一会员接待室时，接待室先判断是否会员已被自己接待过，如果已接待过则拒绝本次接待，如果没有接待过则向上询问是否应该在上一级的更高级别的接待室接待。
 上一级接待室根据接待规则执行同样的处理方法。直到有一级接待室接待或者告诉它下一级这个会员不是自己接待的结果。

 整个JVM平台提供三层ClassLoader:  
 + ***Bootstrap ClassLoader*** \
   主要加载JVM自身工作需要的类，完全是由JVM自己控制，既没有更高一级的父加载器，也没有子加载器。
 + ***ExtClassLoader*** \
   是JVM自身的一部分，服务的特定目标在`System.getProperty("java.ext.dirs")`目录下。
 + ***AppClassLoader*** \
   父类是ExtClassLoader，所有在`System.getProperty("java.class.path")`目录下的类都可以被加载，这个目录就是classpath。  
     
自定义的类加载器，无论是直接实现抽象类ClassLoader，还是继承URLClassLoader类或者其他子类， 父加载器都是AppClassLoader，因为不管调用哪个父类构造器，创建的对象都必须最终调用```getSystemClassLoader()```作为父加载器，而这方法获取的正是AppClassLoader。  
   
 Bootstrap ClassLoader不属于JVM的类等级层次，且没有子类。  
 ExtClassLoader的父类不是Bootstrap ClassLoader，ExtClassLoader并没有父类，是应用中的顶层父类。  
 ExtClassLoader和AppClassLoader都位于sun.misc.Launcher类中，是Launcher的内部类。 
 在创建Launcher对象时首先会创建ExtClassLoader，然后ExtClassLoader对象作为父加载器创建AppClassLoader对象， 
 通过Launcher.getClassLoader()方法获取的ClassLoader就是AppClassLoader对象。 如果在Java应用中没有定义其他ClassLoader，那么除了System.getProperty("java.ext.dirs")目录下的类是由ExtClassLoader加载外，其他类都由AppClassLoader来加载。  
      
 JVM加载class文件到内存有两种方式：
 - 隐式加载  
   不通过在代码里调用ClassLoader来加载需要的类，而是通过JVM来自动加载需要的类到内存的方式。
 - 显式加载  
   在代码中通过调用ClassLoader类来加载一个类的方式。
   
## 三、如何加载class文件
  ClassLoader加载一个class文件到JVM时的步骤：  
  第一阶段：找到.class文件并把文件包含的字节码加载到内存中  
  第二阶段：分为三个步骤，分别是字节码验证、Class类数据结构分析及相应内存分配、符号表的链接  
  第三阶段：类中静态属性和初始化赋值，以及静态块的执行等  
  
#### 加载字节码到内存
 抽象类ClassLoader中没有定义如何找到指定类并把字节码加载到内存中，这需要子类的findClass()方法来实现。在`URLClassLoader`中通过一个`URLClassPath`类帮助取得要加载的class文件字节流，
 `URLClassPath`定义了在哪里查找class文件并读取byte字节流，通过调用defineClass()方法来创建类对象。  
 想要创建`URLClassLoader`对象，必须要指定一个URL数组，也就是必须指定ClassLoader默认到哪个目录下去查找class文件。URL数组也是创建`URLClassPath`对象的必要条件。
 创建`URLClassPath`对象时，会根据URL数组中的路径判断是文件还是jar包，根据路径不同分别创建`FileLoader`或`JarLoader`，或者使用默认的加载器。
 JVM调用findClass时由这几个加载器来将class文件的字节码加载到内存中。  

 | ClassLoader类型 | 参数项 | 说明 |
 | :-------------- | :------------- | :------------------------ | 
 | Bootstrap ClassLoader | -Xbootclasspath[/a][/p]: | 设置Bootstrap ClassLoader的搜索路径 (a代表把路径添加到已存在的后面，p代表添加到前面) |
 | ExtClassLoader | -Djava.ext.dirs | 设置ExtClassLoader的搜索路径 |
 | AppClassLoader | -Djava.class.path= 或 -cp 或 -classpath | 设置AppClassLoader的搜索路径 |

#### 验证与解析
 - 字节码验证：类加载器对类的字节码做校验，确保格式正确、行为正确
 - 类准备：准备代表每个类中定义的字段、方法和实现接口所必需的数据结构
 - 解析：类加载器装入类所引用的其他所有类
 
#### 初始化Class对象
 在类中包含的静态初始化器都被执行，在这一阶段末尾静态字段被初始化为默认值。
 
## 四、常见加载类错误分析
 执行Java程序时经常会遇到ClassNotFoundException和NoClassDefFoundError两个异常，它们都和类加载有关。
 
#### ClassNotFoundException
 通常发生在显式加载类的时候，通常有如下方式：
 + 通过类Class中的forName()方法
 + 通过类ClassLoader中的loadClass()方法
 + 通常类ClassLoader中的findSystemClass()方法
 
 出现这类错误是当JVM要加载指定文件的字节码到内存时，没有找到文件对应的字节码。解决办法是检查当前classpath目录下有没有指定的文件存在。
 获取当前路径的命令：  
 ```
    this.getClass().getClassLoader().getResource("").toString()
 ```
 
#### NoClassDefFoundError
 出现NoClassDefFoundError可能的情况是使用了new关键字、属性引用某个类、继承了某个接口或类，以及方法的某个参数中引用了某个类，
 这时会触发JVM隐式加载这些类时发现这些类不存在的异常。  
 解决这个错误的方法是确保每个类引用的类都在当前的classpath下。
 
#### UnstatisfiedLinkError
 通常是在JVM启动的时候，不小心将在JVM中的某个lib删除了，会报这个错。
 
#### ClassCastException
 通常在程序中出现强制类型转换时出现这个错误。JVM在做类型转换时检查规则如下：
 + 对于普通对象，对象必需是目标类的实例或目标类的子类的实例。如果目标是一个接口，那么会把它当成实现了该接口的一个子类。
 + 对于数组类类型，目标类必须是数组类型或java.lang.Object、java.lang.Cloneable、java.io.Serializable。  
 
 如果不满足上述规则，JVM会报ClassCastException异常。避免方式：
 + 容器类型中显式地指明容器包含的对象类型。
 + 先通过instanceof检查是不是目标类型，然后再进行强制类型转换。
 
#### ExceptionInitializerError 
 JVM对ExceptionInitializerError错误的定义：
 - 如果Java虚拟机试图创建类ExceptionInitializerError的新实例，但因为出现Out-Of-Merrory-Error而无法创建新实例，就抛出OutOfMemoryError对象作为替代。
 - 如果初始化器抛出一些Exception，而且Exception类不是Error或者它的某个子类，就会创建ExceptionInitilizerError类的一个新示例，并用Exception作为参数，用这个实例代替Exception。 

## 五、常用的ClassLoader分析
 一个应用在Tomcat中由一个StandardContext表示，由StandardContext来解释Web应用的`web.xml`配置文件实例化所有的Servlet。
 Servlet的class是由<servlet-class>来指定的，所以每个Servlet类的加载肯定是通过显式加载方法加载到Tomcat容器中的。
 Servlet的ClassLoader是`WebappClassLoader`。`WebappClassLoader`覆盖了父类的`loadClass`方法，使用自己的加载机制，步骤为：
 1. 检查在`WebappClassLoader`中是否已经加载过，如果加载过则在`WebappClassLoader`的缓存容器`resourceEntries`中。
 2. 如果不存在，则继续检查在JVM虚拟机中是否已加载过，即调用`ClassLoader`的`findLoadedClass`方法。
 3. 如果在前两个缓存中都没有，则先调用`SystemClassLoader`（即`AppClassLoader`）加载请求的类，也就是在当前JVM的ClassPath路径下查找请求的类。
 4. 如果请求的类在packageTrigger定义的包名下，则将通过`StandardClassLoader`类来加载。
 5. 仍未找到，将由`WebappClassLoader`来加载，在应用的`WEB-INF/classes`目录下查找请求的类文件的字节码。
  找到后创建一个`ResourceEntry`对象保存类的元信息，并保存到`ResourceEntries`容器中便于下次查找。
  接着调用`defineClass`方法生成请求类的Class对象并返回给InstanceManager来创建实例。 
  
## 六、实现自定义ClassLoader
 
 
 
 
 
 
 
 
 
 
 
 
 
 