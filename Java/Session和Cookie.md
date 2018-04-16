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
 
 
 
 
 