# Session和Cookie #
Session和Cookie的作用都是为了保持访问用户与后端服务器的交互状态。  

## Cookie ##
 当用户通过HTTP访问一个服务器时，服务器会将一些key/value键值对返回给客户端浏览器，
 并给这些数据加上一些限制条件，在条件符合时用户下次访问服务器时，数据又被完整的带回到服务器。  
 设计Cookie是为了记录用户在一段时间内访问Web应用的行为路径。
 HTTP是一种无状态协议，当用户的一次访问请求结束后，后端服务器就无法知道下一次访问的是不是上次访问的用户。  
### Cookie属性项 ###
 当前Cookie有两个版本：`Version 0` 和`Version 1`，响应报文头的标识分别为`Set-Cookie`和`Set-Cookie2`。  
 Version 0 属性项介绍 
  <table>
  <thead>
  <th>属性项</th>
  <th>属性项介绍</th>
  </thead>
  <tbody>
  <tr>
    <td>NAME=VALUE</td>
    <td>键值对，可以设置要保存的Key/Value，注意NAME不能和其他属性项的名字一样</td>
  </tr>
   <tr>
     <td>Expires</td>
     <td>过期时间，在设置的某个时间点后该Cookie失效</td>
   </tr>
   <tr>
    <td>Domain</td>
    <td>生成该Cookie的域名，如domain="www.baidu.com"</td>
   </tr>
   <tr>
    <td>Path</td>
    <td>该Cookie是在当前的哪个路径下生成的，如path=/wp-admin/</td>
   </tr>
   <tr>
    <td>Secure</td>
    <td>如果设置了这个属性，那么只会在SSH链接时才会回传该Cookie</td>
   </tr>
  </tbody>
  </table>
 Version 1的属性项  
   <table>
   <thead>
   <th>属性项</th>
   <th>属性项介绍</th>
   </thead>
   <tbody>
   <tr>
     <td>NAME=VALUE</td>
     <td>键值对，可以设置要保存的Key/Value，注意NAME不能和其他属性项的名字一样</td>
   </tr>
   <tr>
     <td>Version</td>
     <td>通过Set-Cookie2设置的响应头创建必须符合RFC2965规范，如果通过Set-Cookie响应头设置，则默认为0；如果设置为1，则该Cookie要遵循RFC2109规范</td>
   </tr>
   <tr>
    <td>Comment</td>
    <td>注释项，用户说明该Cookie有何用途</td>
   </tr>
   <tr>
    <td>CommentURL</td>
    <td>服务器为此Cookie提供的URI注释</td>
   </tr>
   <tr>
    <td>Discard</td>
    <td>是否会在结束后丢弃该Cookie项，默认为false</td>
   </tr>
   <tr>
    <td>Domain</td>
    <td>生成该Cookie的域名，如domain="www.baidu.com"</td>
   </tr>
   <tr>
    <td>Max-Age</td>
    <td>最大失效时间，与Version0不同的是这里设置的是多少秒后失效</td>
   </tr>
   <tr>
    <td>Path</td>
    <td>该Cookie是在当前的哪个路径下生成的，如path=/wp-admin/</td>
   </tr>
   <tr>
    <td>Port</td>
    <td>该Cookie在什么端口下可以回传服务器，如果有多个端口，则以逗号隔开，如Port="80,81,8080"</td>
   </tr>
   <tr>
    <td>Secure</td>
    <td>如果设置了这个属性，那么只会在SSH链接时才会回传该Cookie</td>
   </tr>
   </tbody>
  </table>
  
### Cookie如何工作 ###
 创建Cookie：
 ```Java  
 String getCookie(Cookie[] cookies, String key) {
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals(key)) {
                return cookie.getValue();
            }
        }
    }
    return null;
 }
 
 @Override
 public void doGet(HttpServvletRequest request, HttpSerletResponse response) 
    throws IOException, ServletException {
    Cookie[] cookies = request.getCookies();
    String userName = getCookie(cookies, "userName");
    String userAge = getCookie(cookies, "userAge");
    if (userName == null) {
        response.addCookie(new Cookie("userName", "McHeat"));
    }
    if (userAge == null) {
        response.addCookie(new Cookie("userAge", "28"));
    }
    response.getHeaders("Set-Cookie");
 }
 ```
 在Tomcat中，真正构建Cookie的是在`org.apache.catalina.connector.Respose`类中完成，
 调用`generateCookieString`方法将Cookie对象构造成一个字符串，然后将字符串命名为`Set-Cookie`
 添加到MimeHeaders中。  
 每次调用`addCookie`方法时，最终都会创建一个Header,在构建HTTP返回字节流时将Header中所有的项数序写出而没有进行任何修改，
 所以浏览器在接受HTTP返回的数据时是分别解析每一个Header项的。当请求某个URL路径时，浏览器会根据URL路径将符合条件的Cookie
 放在Request请求头中传回服务端，服务端通过`request.getCookie()`来取得所有Cookie。  
 
### 使用Cookie的限制 ###
 Cookie在HTTP中的一个字段，最终存储在浏览器里，所以不同的浏览器对Cookie的存储都有一些限制。  
 
## Session ##
 同一个客户端每次和服务端交互时，不需要每次都传回所有的Cookie值，而是只要传回一个ID，这个ID是客户端第一次访问服务器时生成的，
 而且每个客户端是唯一的，所以客户端只要传回这个ID就行了，通常是NAME为JSESSIONID的一个Cookie。  
 
### Session工作
 Session正常工作的三种方式：  
 + 基于URL Path Parameter，默认支持  
    当浏览器不支持Cookie功能时，会将用户的SessionCookieName重写到用户请求的URL参数中。
    传递格式为：/path/Servlet;name=value;name2=value2?name3=value3
 + 基于Cookie，如果没修改Context容器的Cookies标识，则默认支持  
    客户端支持Cookie，则Tomcat仍然会解析Cookie中的Session ID，并会覆盖URL中的Session ID。
 + 基于SSL，默认不支持，只有`connector.getAttribute("SSLEnabled")`为TRUE才支持  
    根据`javax.servlet.request.ssl_session`属性值设置Session ID。

 当有了SessionID，服务端就可以创建HttpSession对象，第一次触发是通过`request.getSession()`方法。如果没有对应的HttpSession对象，就会创建新的对象并
 添加到`org.apache.catalina.Manager`的sessions容器中保存。`org.apache.catalina.Manager`类的实现类是`org.apache.catalina.session.StandardManager`，
 通过requestedSessionId从StandardManager的session集合中取出StandardSession对象。
 一个requestedSessionId对应一个访问的客户端，所以一个客户端对一个StandardSession对象，其中保存了Session的值。
   
 StandardManager类负责Servlet容器中所有的StandardSession对象的生命周期管理。当Servlet容器关闭时，StandardManager类会调用unload方法将sessions
 集合中的StandardSession对象写到"SESSIONS.ser"文件中，然后在启动时重新恢复。持久化session对象必须调用Servlet容器的stop和start命令，
 而不能直接结束（kill）Servlet容器的进程。  
 
 必须给每个Session对象定义一个有效时间，超过这个时间则Session对象将被清除。检查Session是否失效是在Tomcat的一个后台线程中完成，或调用`request.getSession()`
 时。
 
##  Cookie安全问题    ##
 Cookie通过把所有保存的数据通过HTTP头部从客户端传递到服务端，又从服务端再传回客户端，所有数据都存储在客户端的浏览器里，所以Cookie的安全性受到很大的挑战。  
 
 相比较而言，Session的安全性要高很多，因为Session是将数据保存在服务端，只通过Cookie传递一个SessionID而已，所以Session更适合存储用户隐私和重要的数据。


















 
 
 
 