# Resources
## 一、介绍
 Java中标准的`java.net.URL`类和针对不同URL前缀的标准处理类对底层资源的利用并不充分。
 例如，当前没有可用的标准`URL`实现类能够从类路径或`ServletContext`的相对路径获取资源。
 注册特定`URL`前缀的新处理器是可行的方式，但是这种方式通常相当复杂。
 同时`URL`接口缺乏一些实用的功能，比如判断指定的资源是否存在的方式。  
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
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 