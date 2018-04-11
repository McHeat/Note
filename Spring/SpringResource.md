# Resources
## 一、介绍
 Java中标准的`java.net.URL`类和针对不同URL前缀的标准处理类对底层资源的利用并不充分。例如，当前没有可用的标准`URL`实现类能够从类路径或`ServletContext`的相对路径获取资源。注册特定`URL`前缀的新处理器是可行的方式，但是这种方式通常相当复杂。同时`URL`接口缺乏一些实用的功能，比如判断指定的资源是否存在的方式。  
## 二、Resource接口
 相对于`URL`接口，Spring的`Resource`接口在使用底层资源上功能更丰富。
 ```
 public interface Resource extends InputStreamSource {

    boolean exists();

    boolean isOpen();

    URL getURL() throws IOException;

    File getFile() throws IOException;

    Resource createRelative(String relativePath) throws IOException;

    String getFilename();

    String getDescription();
 }
 ```
 ```
 public interface InputStreamSource {
    InputStream getInputStream() throws IOException;
 }
 ```
 `Resource`接口中的一些重要方法是：  
 + `getInputStream()`：定位和打开资源，返回从资源中读取到的`InputStream`。方法的每次调用都应该返回一个新的`InputStream`。调用者必须关闭这个流。  
 + `exists()`：返回一个boolean值，表示资源是否在物理设备上存在。  
 + `isOpen()`：返回一个boolean值，表示资源是否表示为对已开启流的操作。如果为true，则`InputStream`不能多次读取，只能读取一次然后关闭防止资源泄漏。除了`InputStream` 外，其他所有的resource实现类都是false。
 + `getDescription()`：返回对资源的描述，用于处理资源时的异常输出。通常是文件的全路径名称或资源的实际URL。  
 
 如果底层的实现类支持，其他方法允许你获取代表资源的实际`URL`或`File`对象。  
 在Spring中，`Resource`抽象接口应用广泛，在需要时会作为方法签名的一个参数类型。而在Spring API的其他方法（比如各种`ApplicationContext`实现类的构造器）中，通过字符串创建适合context实现类的`Resource`，或者通过字符串路径的指定前缀，允许调用者声明指定的`Resource`实现类必须被创建或使用。  
 `Resource`接口在Spring中使用广泛。即使在你代码中并不使用Spring时，`Resource`本身也是一个处理资源的有效工具类。这会将代码与Spring耦合，但是也仅仅是耦合了`URL`的更丰富的替代工具类集，等价于为这个目的使用的其他jar包。  
 值得注意的是，`Resource`抽象接口并不会替换功能类，它仅仅是包装了这个功能类。比如，`URLResource`包装了URL，并通过这个包装的`URL`来处理资源。
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 