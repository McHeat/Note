#75. Embedded Web Servers嵌入式网络服务器
每个Spring Boot web application包括一个嵌入式web server。这个特性就导致了许多“怎样做”的问题，包括如何更改embedded server 以及如何配置 embedded server。本节就回答了此类问题。
## 75.1 Use Another Web Server使用另外的网络服务器
许多 Spring Boot starters 包含默认的embedded containers。`spring-boot-starter-web`包含Tomcat ，通过调用 `spring-boot-starter-tomcat`，但是你也可以使用`spring-boot-starter-jetty` 或 `spring-boot-starter-undertow `。 `spring-boot-starter-webflux` 调用Reactor Netty ，通过调用 `spring-boot-starter-reactor-netty`，可以使用`spring-boot-starter-tomcat`，`spring-boot-starter-jetty`或`spring-boot-starter-undertow `作为替代。

[Note]
许多starters仅支持Spring MVC, 因此它们可传递性地将`spring-boot-starter-web` 带到你程序的classpath中。

如果需要使用不同的 HTTP server，就需要你拒绝（exclude ）默认的 dependencies 并允许（ include ）所需的那一个。Spring Boot 为HTTP servers提供单独的 starters 用以使程序尽可能的简单。

 下列Maven example 展示了为Spring MVC如何exclude Tomcat 以及 include Jetty ：

```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
	<exclusions>
		<!-- Exclude the Tomcat dependency -->
		<exclusion>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-tomcat</artifactId>
		</exclusion>
	</exclusions>
</dependency>
<!-- Use Jetty instead -->
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-jetty</artifactId>
</dependency>

```

下面的 Gradle example展示了为Spring WebFlux如何 exclude Netty 以及 include Undertow  :
```java
configurations {
	// exclude Reactor Netty
	compile.exclude module: 'spring-boot-starter-reactor-netty'
}

dependencies {
	compile 'org.springframework.boot:spring-boot-starter-webflux'
	// Use Undertow instead
	compile 'org.springframework.boot:spring-boot-starter-undertow'
	// ...
}
```

[Note]
`spring-boot-starter-reactor-netty`需要使用 `WebClient `class，因此你需要为Netty保留一个dependency 即使你需要调用不同的  HTTP server。

((##75.2 Disabling the Web Server（2.0.1版本中没有）
 如果你的classpath 包含启动web server的 necessary bits，Spring Boot 将会自动启动它 。想要使此行为失效，可以在你的`application.properties`中如下配置 `WebApplicationType`：

`spring.main.web-application-type`=none))

##75.2 Configure Jetty
一般你可以参照74.8章[ “Section 74.8, “Discover Built-in Options for External Properties”” ]中关于 `@ConfigurationProperties` 的内容(`ServerProperties` 是最主要的内容)。然而，你也应该查看[`WebServerFactoryCustomizer`](https://docs.spring.io/spring-boot/docs/2.0.1.RELEASE/api/org/springframework/boot/web/server/WebServerFactoryCustomizer.html)。Jetty APIs是相当丰富的，因此一旦你可以使用`JettyServletWebServerFactory`，就可以使用很多种方法来改变它。另一方面如果你需要更多的控制与定制，你可以添加自己的`JettyServletWebServerFactory`。


##75.3 Add a Servlet, Filter, or Listener to an Application
有两种方式来添加 `Servlet`，`Filter`，`ServletContextListener`，以及其他Servlet支持的指定到你的程序的listeners ：

即接下来的两小节
[Section 75.3.1, “Add a Servlet, Filter, or Listener by Using a Spring Bean”]
[Section 75.3.2, “Add Servlets, Filters, and Listeners by Using Classpath Scanning”]

###75.4.1 Add a Servlet, Filter, or Listener by Using a Spring Bean

通过使用Spring bean来添加`Servlet`, `Filter`, 或 `Servlet *Listener` ，你必须提供一个为其定义的`@Bean` 。当你想要插入configuration 或 dependencies时这样做是非常有用的。然而，你必须要注意，力求它们不会引发太多其它的beans的eager initialization，因为它们会在程序lifecycle的早期就被安装在container中。（例如，根据你的`DataSource`或JPA configuration来获取它们并不是一个好方法) 。通过在初次使用时惰性（lazily）初始化beans来解决这类限制，而非初始化时。

在`Filters` and `Servlets`下，你也可以通过添加 `FilterRegistrationBean` 或`ServletRegistrationBean` 来添加mappings以及init parameters，而非底层构间（underlying component）。

[Note]
如果在filter registration中没有 `dispatcherType`被特殊说明，`REQUEST`就是在使用的。这个与Servlet Specification’s default dispatcher type相匹配。
与其他 Spring bean类似，你可以定义Servlet filter beans的顺序; 请务必查看“[the section called “Registering Servlets, Filters, and Listeners as Spring Beans””](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#boot-features-embedded-container-servlets-filters-listeners-beans)此章节。

**Disable Registration of a Servlet or Filter**

在[先前描述中](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-add-a-servlet-filter-or-listener-as-spring-bean)中，任何`Servlet` 或 `Filter` beans 都被自动登记到servlet container中。为使特定的Filter or Servlet bean的登记失效，可为其创建一个registration bean 并标记其为disabled,如下例所示：
```
@Bean
public FilterRegistrationBean registration(MyFilter filter) {
	FilterRegistrationBean registration = new FilterRegistrationBean(filter);
	registration.setEnabled(false);
	return registration;
}
```

###75.3.2 Add Servlets, Filters, and Listeners by Using Classpath Scanning

`@WebServlet`, `@WebFilter`, 以及` @WebListener` annotated classes可以自动注册到嵌入式的servlet container，通过使用`@ServletComponentScan` 以及指定封装了你想要注册的构件的package(s)来注解 `@Configuration` class。默认，`@ServletComponentScan`从注解过的class的package中进行扫描。

## 75.4 Change the HTTP Port
在独立程序中，主 HTTP port默认为8080，不过可以使用`server.port`对其进行设置 (例如，在`application.properties` 中或作为System property)。由于`Environment` values的relaxed binding，你也可以使用`SERVER_PORT` （例如，作为一个OS environment variable)。

要完全关闭 HTTP endpoints但还要要创建一个`WebApplicationContext`，使用`server.port=-1`。（测试时这样做是很有用的）

查看 [“Section 27.4.4, “Customizing Embedded Servlet Containers””](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#boot-features-customizing-embedded-containers)或[ServerProperties]( https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/ServerProperties.java) 源代码获取更多细节。 

## 75.5 Use a Random Unassigned HTTP Port
扫描free port (使用OS natives来预防冲突)使用`server.port=0`。

## 75.6 Discover the HTTP Port at Runtime
You can access the port the server is running on from log output or from the `ServletWebServerApplicationContext` through its `WebServer`。获取以及并确保其被初始化的最好的方式是添加`ApplicationListener<ServletWebServerInitializedEvent>`类型的  `@Bean` 并其被 publish时将container从事件event中拉出。

通过`@LocalServerPort` annotation，使用`@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)`的测试也可以将 actual port插入到field。就如下所示：

```
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)
public class MyWebIntegrationTests {

	@Autowired
	ServletWebServerApplicationContext server;

	@LocalServerPort
	int port;

	// ...

}
```

[Note]

`@LocalServerPort`是对`@Value("${local.server.port}")`的一个meta-annotation。不要尝试去将此port插入到正规程序？？（regular application）。就像我们刚刚所说的那样，该值只设置在被初始化的container后。与test相反，application code callbacksare processed early (在value实际可用之前)。

## 75.7 Configure SSL

SSL可以通过设置多种`server.ssl.*`properties来进行明确配置，特别是在`application.properties` 或`application.yml`中。下例中展示了如何在`application.properties`中设置SSL properties：

```
server.port=8443
server.ssl.key-store=classpath:keystore.jks
server.ssl.key-store-password=secret
server.ssl.key-password=another-secret
```

查看[`Ssl`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/server/Ssl.java) 获取所有supported properties得详细信息。

使用上例中的配置意味着程序不再支持a plain HTTP connector at port 8080。Spring Boot 不支持HTTP connector及`application.properties`的HTTPS connector 。如果你两个都想要，需要将其中一个programmatically配置。我们推荐使用
`application.properties`来配置HTTPS, HTTP connector是相对比较容易进行 programmatically配置。查看[`spring-boot-sample-tomcat-multi-connectors`](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-samples/spring-boot-sample-tomcat-multi-connectors) sample project为参考。

## 75.8 Configure HTTP/2

可以在程序中使用`server.http2.enabled` 配置属性来启用HTTP/2支持。这种支持依赖于所选择的web server及程序环境，因为协议在out-of-the-box外是不被JDK8所支持的。

[Note]

Spring Boot不支持`h2c`（HTTP/2 protocol的明文版本）。因此你必须先配置SSL[configure SSL first](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-configure-ssl)。

### 75.8.1 HTTP/2 with Undertow

在Undertow 1.4.0+以上版本， HTTP/2对JDK8不需要任何额外要求就可以获得支持。

### 75.8.2 HTTP/2 with Jetty

在Jetty 9.4.8, HTTP/2也是受[Conscrypt library](https://www.conscrypt.org/)支持。为使支持有效，程序中需要两个附加dependencies: `org.eclipse.jetty:jetty-alpn-conscrypt-server` and `org.eclipse.jetty.http2:http2-server`。

### 75.8.3 HTTP/2 with Tomcat

Spring Boot默认使用Tomcat 8.5.x进行 ships？？。在该版本下，HTTP/2只有在 `libtcnative` library及其dependencies安装在host operating system的情况下才受支持。

if not already,？？ library 文件一定要可被 JVM library path利用。可以用JVM argument如`-Djava.library.path=/usr/local/opt/tomcat-native/lib`来实现。 更多的信息参见[official Tomcat documentation](Apache Tomcat 8 (8.5.31) ((- Apache Portable Runtime (APR) 基于Native library。为Tomcat https://tomcat.apache.org/tomcat-8.5-doc/apr.html)新添加））？？？

启动Tomcat 8.5.x无需本地支持记录（logs）下列error:
```
ERROR 8787 --- [           main] o.a.coyote.http11.Http11NioProtocol      : The upgrade handler [org.apache.coyote.http2.Http2Protocol] for [h2] only supports upgrade via ALPN but has been configured for the ["https-jsse-nio-8443"] connector that does not support ALPN.
```
本 error不是毁灭性的，程序仍然以HTTP/1.1 SSL support启动。

 在Tomcat 9.0.x 下运行你的程序且JDK9不需要安装任何native library。使用Tomcat 9，可以使用你选择的版本重写（override） `tomcat.version` build property。

## 75.9 Configure Access Logging
Access logs可以通过它们分别的namespaces配置到Tomcat，Undertow及 Jetty。

例如，下例使用  [custom pattern](https://tomcat.apache.org/tomcat-8.5-doc/config/valve.html#Access_Logging)在Tomcat中设置log access。

```
server.tomcat.basedir=my-tomcat
server.tomcat.accesslog.enabled=true
server.tomcat.accesslog.pattern=%t %a "%r" %s (%D ms)
```
[Note]
`logs `缺省location是一个与Tomcat相关的logs directory基于directory。默认，the `logs` directory是一个临时directory，因此可能想要基于directory来fix Tomcat’s 或为logs使用absolute path。在前面的例子中，logs在`my-tomcat/logs`中可用，`my-tomcat/logs`与程序的working directory有关。

Undertow为存取logging可以以下面相似的方式进行配置：

```
server.undertow.accesslog.enabled=true
server.undertow.accesslog.pattern=%t %a "%r" %s (%D ms)
```

Logs存储在与程序working directory相关的`logs` directory 中。可以通过设置`server.undertow.accesslog.directory property`来自定义location。

最后 ，为Jetty存取logging也可以按如下方式进行配置：
```
server.jetty.accesslog.enabled=true
server.jetty.accesslog.filename=/var/log/jetty-access.log
```

默认logs定向到`System.err`。详情请参见[Jetty documentation](https://www.eclipse.org/jetty/documentation/9.4.x/configuring-jetty-request-logs.html)。

## 75.10 Running Behind a Front-end Proxy Server

你的程序可能需要利用？absolute links发送`302` redirects或render content返回自身。当在proxy后运行时，caller需要一个到proxy的link并且不到hosting你的程序的机器的physical address。特别是这种情况通过与proxy进行contract（合同？）进行处理，就是添加headers来讲明 back end如何与自身建立连接。

如果proxy添加传统的`X-Forwarded-For`和`X-Forwarded-Proto` headers (大多数proxy servers 是这样做的)，absolute links应该被正确rendered，前提是在你的`application.properties`中`server.use-forward-headers`被设置为`true` 。

[Note]
如果你的程序是运行在 Cloud Foundry或Heroku下，`server.use-forward-headers `property默认为`true`。在所有其他实例中，默认为 `false`。

### 75.10.1 Customize Tomcat’s Proxy Configuration

如果使用Tomcat，可以使用下述方式额外配置 headers名（用于carry “forwarded”信息）： 

```
server.tomcat.remote-ip-header=x-your-remote-ip-header
server.tomcat.protocol-header=x-your-protocol-header

```

Tomcat也可以使用默认的regular expression进行配置，其符合被信任的内部proxies。默认IP addresses在`10/8`, `192.168/16`, `169.254/16`以及`127/8`被信任。可以通过添加`application.properties`入口来自定义配置值，就如下所示：
```
server.tomcat.internal-proxies=192\\.168\\.\\d{1,3}\\.\\d{1,3}
```
[Note]
双反斜线只有在你使用properties文件进行配置时需要。如果你使用YAML，单反斜线就可以了，并且上例中（相应的值）value equivalent是`192\.168\.\d{1,3}\.\d{1,3}`.
[Note]

你可以通过设置`internal-proxies`为empty来信任所有的proxies（在成品中不需要这样做）。
可以通过关闭automatic one（设置`server.use-forward-headers=false`可以做到）并 在`TomcatServletWebServerFactory` bean中附加新的valve instance来完全控制Tomcat’s `RemoteIpValve` 配置。

## 75.11 Configure Tomcat
一般你可以按照[“Section 74.8, “Discover Built-in Options for External Properties”” ](Spring Boot Reference Guide  https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-discover-build-in-options-for-external-properties)中介绍的关于`@ConfigurationProperties` (`ServerProperties`是最主要的)来进行。然而你也应该看看你可以添加的`WebServerFactoryCustomizer`以及多种Tomcat-specific `*Customizers`。Tomcat APIs是相当丰富的。结果一旦你使用`TomcatServletWebServerFactory`，你可以用多种方式对其进行修改。作为选择的，如果你需要进行更多控制及自定义可以添加自己的`TomcatServletWebServerFactory`。

## 75.12 Enable Multiple Connectors with Tomcat
你可以添加`org.apache.catalina.connector.Connector`到`TomcatServletWebServerFactory`，就可以允许多重连接，包括HTTP以及HTTPS connectors，如下所示：

```
@Bean
public ServletWebServerFactory servletContainer() {
	TomcatServletWebServerFactory tomcat = new TomcatServletWebServerFactory();
	tomcat.addAdditionalTomcatConnectors(createSslConnector());
	return tomcat;
}

private Connector createSslConnector() {
	Connector connector = new Connector("org.apache.coyote.http11.Http11NioProtocol");
	Http11NioProtocol protocol = (Http11NioProtocol) connector.getProtocolHandler();
	try {
		File keystore = new ClassPathResource("keystore").getFile();
		File truststore = new ClassPathResource("keystore").getFile();
		connector.setScheme("https");
		connector.setSecure(true);
		connector.setPort(8443);
		protocol.setSSLEnabled(true);
		protocol.setKeystoreFile(keystore.getAbsolutePath());
		protocol.setKeystorePass("changeit");
		protocol.setTruststoreFile(truststore.getAbsolutePath());
		protocol.setTruststorePass("changeit");
		protocol.setKeyAlias("apitester");
		return connector;
	}
	catch (IOException ex) {
		throw new IllegalStateException("can't access keystore: [" + "keystore"
				+ "] or truststore: [" + "keystore" + "]", ex);
	}
}
```

## 75.13 Use Tomcat’s LegacyCookieProcessor
默认，Spring Boot使用的内嵌的Tomcat不支持Cookie格式的"Version 0"，因此你可以看到如下的错误：

```
java.lang.IllegalArgumentException: An invalid character [32] was present in the Cookie value

```

If at all possible, you should consider updating your code to only store values compliant with later Cookie specifications。 然而，如果你不能改变写cookies方式，可以使用`LegacyCookieProcessor`替代配置Tomcat。改变 `LegacyCookieProcessor`，使用`WebServerFactoryCustomizer` bean添加`TomcatContextCustomizer`，如下所示：

```
@Bean
public WebServerFactoryCustomizer<TomcatServletWebServerFactory> cookieProcessorCustomizer() {
	return (factory) -> factory.addContextCustomizers(
			(context) -> context.setCookieProcessor(new LegacyCookieProcessor()));
}
```

## 75.14 Configure Undertow
一般可按照[“Section 74.8, “Discover Built-in Options for External Properties”” ](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-discover-build-in-options-for-external-properties)关于`@ConfigurationProperties` (`ServerProperties` 及`ServerProperties.Undertow` 是主要内容)的描述。然而，你也应当看看`WebServerFactoryCustomizer`。一旦你存取`UndertowServletWebServerFactory`，可以使用`UndertowBuilderCustomizer`来修改Undertow’s的配置，以满足需求。作为选择，如果你有更多控制与自定义需求，你可以添加自己的`UndertowServletWebServerFactory`。

## 75.15 Enable Multiple Listeners with Undertow
添加`UndertowBuilderCustomizer`到`UndertowServletWebServerFactory` 并添加一个listener到`Builder`，如下所示：

```
@Bean
public UndertowServletWebServerFactory servletWebServerFactory() {
	UndertowServletWebServerFactory factory = new UndertowServletWebServerFactory();
	factory.addBuilderCustomizers(new UndertowBuilderCustomizer() {

		@Override
		public void customize(Builder builder) {
			builder.addHttpListener(8080, "0.0.0.0");
		}

	});
	return factory;
}
```

## 75.16 Create WebSocket Endpoints Using @ServerEndpoint

如果你想要在一个使用内嵌container的Spring Boot程序中使用`@ServerEndpoint`，必须声明一个单独的`ServerEndpointExporter` `@Bean`，如下所示：

```
@Bean
public ServerEndpointExporter serverEndpointExporter() {
	return new ServerEndpointExporter();
}
```
上例中展示的bean registers any `@ServerEndpoint` annotated beans with the underlying WebSocket container.当部署 When deployed to a standalone servlet container，该role通过servlet container initializer来执行，并且不需要`ServerEndpointExporter` bean。

## 75.17 Enable HTTP Response Compression
HTTP response compression受Jetty，Tomcat以及Undertow支持。 可以在`application.properties`中起效，如下所示：

```
server.compression.enabled=true
```
默认，responses至少要compression有2048 bytes来执行。可以通过设置`server.compression.min-response-size` property进行配置。

默认，responses are compressed只有在content type是下列之一的情况下才可以：

- `text/html`
- `text/xml`
- `text/plain`
- `text/css`

通过设置`server.compression.mime-types` property进行配置。

# 76. Spring MVC
Spring Boot包括Spring MVC，有许多starters。注意一些starters包含dependency on Spring MVC rather than include it directly。本节回答了关于Spring MVC及 Spring Boot的一般性问题。

## 76.1 Write a JSON REST Service
在Spring Boot程序中的任何Spring `@RestController`默认在Jackson2在classpath 中时保持render JSON response，如下例所示：

```
@RestController
public class MyController {

	@RequestMapping("/thing")
	public MyThing thing() {
			return new MyThing();
	}

}
```
只要`MyThing`能被Jackson2 (true for a normal POJO or Groovy object)连载（serialized），那么默认[localhost:8080/thing](http://localhost:8080/thing) serves a JSON representation of it。注意，在浏览器中，你可能有时会看到XML 响应，因为浏览器倾向于发送responses, because browsers tend to send accept headers that prefer XML.

## 76.2 Write an XML REST Service
如果你在classpath中有Jackson XML extension (`jackson-dataformat-xml`)，就可以使用它来render XML responses，前面我们用于JSON的例子就会起效。要使用Jackson XML renderer, 添加下面的dependency到你的project:

```
<dependency>
	<groupId>com.fasterxml.jackson.dataformat</groupId>
	<artifactId>jackson-dataformat-xml</artifactId>
</dependency>
```

你可能也想要为Woodstox 添加一个dependency。他会比JDK默认提供的StAX implementation更快，并且添加pretty-print支持，且会改善namespace handling。下述列表显示了如何在[ Woodstox](https://github.com/FasterXML/woodstox)include a dependency：

```
<dependency>
	<groupId>org.codehaus.woodstox</groupId>
	<artifactId>woodstox-core-asl</artifactId>
</dependency>
```
如果Jackson’s XML extension不可用， 就会使用JAXB (JDK默认提供)，含有使用了注释为`@XmlRootElement`的`MyThing` 的额外要求，如下所示：

```
@XmlRootElement
public class MyThing {
	private String name;
	// .. getters and setters
}
```
要获得server来render XML而非JSON，你可能需要发送`Accept: text/xml` header (或使用browser)。

## 76.3 Customize the Jackson ObjectMapper

Spring MVC (客户端及服务器端)使用`HttpMessageConverters`来在HTTP exchange 中进行negotiate content conversion。如果Jackson在classpath中，你已经获得由`Jackson2ObjectMapperBuilder`提供的默认converter(s)，为你提供自动配置的实例。

`ObjectMapper` （或Jackson XML converter的`XmlMapper` ）实例（默认创建）具有下列自定义属性（customized properties）：

- `MapperFeature.DEFAULT_VIEW_INCLUSION` is disabled
- `DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES` is disabled
- `SerializationFeature.WRITE_DATES_AS_TIMESTAMPS` is disabled

 Spring Boot也具有一些特征，能够使其进行自定义行为时更加容易。

You can configure the  by using the .  provides an extensive suite of simple on/off features that can be used to configure various aspects of its processing. These features are described in s
你可以通过使用environment来 配置`ObjectMapper` and `XmlMapper` instances。Jackson提供简单on/off的额外组件，可以用于配置其进程的多种方面。这些特点在定位于environment properties的六种enums (in Jackson)进行描述:

**Jackson enum**	**Environment property**
`com.fasterxml.jackson.databind.DeserializationFeature`

`spring.jackson.deserialization.<feature_name>=true|false`

`com.fasterxml.jackson.core.JsonGenerator.Feature`

`spring.jackson.generator.<feature_name>=true|false`

`com.fasterxml.jackson.databind.MapperFeature`

`spring.jackson.mapper.<feature_name>=true|false`

`com.fasterxml.jackson.core.JsonParser.Feature`

`spring.jackson.parser.<feature_name>=true|false`

`com.fasterxml.jackson.databind.SerializationFeature`

`spring.jackson.serialization.<feature_name>=true|false`

`com.fasterxml.jackson.annotation.JsonInclude.Include`

`spring.jackson.default-property-inclusion=always|non_null|non_absent|non_default|non_empty`

例如，要使用pretty print，设置`spring.jackson.serialization.indent_output=true`。注意，由于使用
[relaxed binding](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#boot-features-external-config-relaxed-binding)，`indent_output`的情况不需要与相对应的enum constant匹配，即 `INDENT_OUTPUT`。

这种基于环境的配置方式适用于自动配置的`Jackson2ObjectMapperBuilder` bean以及任何通过builder创建的所有mappers，包括自动配置的`ObjectMapper` bean。

`Jackson2ObjectMapperBuilder`可以使用一个或多个`Jackson2ObjectMapperBuilderCustomizer` beans进行自定义。这类自定义beans可被ordered (Boot自己的自定义顺序？（order）为0)，使附加自定义能适用于 Boot的 customization之前或之后。

任何`com.fasterxml.jackson.databind.Module`类型的beans都是自动登记到自动配置的`Jackson2ObjectMapperBuilder`，并且适用于任何它创建的`ObjectMapper` instances。当你为你的程序添加新的features时，这就为建造custom modules提供了global 机制。

如果你想要完全替代默认的`ObjectMapper`，要不定义一个该类型的`@Bean`并标记为`@Primary`，要么，如果你更喜欢基于编译器的方式，定义一个 `Jackson2ObjectMapperBuilder` `@Bean`。注意，在两种方式中，都需要使所有`ObjectMapper`的自动配置实效。

如果你提供任何`MappingJackson2HttpMessageConverter`类型的`@Beans`，它们都会替代MVC 配置的缺省值。并且提供`HttpMessageConverters`类型的convenience bean（并且如果是使用默认MVC configuration就总是可用）。有很多有用方式来存取缺省值以及（用户增强版信息转换器）user-enhanced message converters。
查看 [“Section 76.4, “Customize the @ResponseBody Rendering””](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-customize-the-responsebody-rendering) 章节以及[WebMvcAutoConfiguration](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/servlet/WebMvcAutoConfiguration.java) source code获取更多详细信息。

## 76.4 Customize the @ResponseBody Rendering

Spring使用`HttpMessageConverters`来render `@ResponseBody `(或来自 `@RestController`的响应)。可以通过在Spring Boot context中添加appropriate类型的beans来contribute additional converters。

如果你添加的bean是可以总是被默认include的类型(例如 `MappingJackson2HttpMessageConverter` for JSON conversions)，它会替代缺省值。A  of type 如果你使用缺省的 MVC configuration，可提供`HttpMessageConverters`类型的convenience bean并且总是可用的。有一些有用的方法来存取缺省值和user-enhanced message converters (例如，如果你想要手动将其插入到custom `RestTemplate`时是很有用的)。

在一般的MVC使用时，任何你提供的`WebMvcConfigurer` beans也通过覆盖 `configureMessageConverters` method来contribute converters。然而，与一般的MVC不同，你只可以支持你需要的additional converters(因为Spring Boot使用同样的机制来 contribute它的默认值)。最后，如果你通过提供自己的`@EnableWebMvc` configuration来opt out of the Spring Boot default MVC configuration，就可以完全控制及通过使用`WebMvcConfigurationSupport`的 `getMessageConverters`来手动完成每件事。
查看[`WebMvcAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/servlet/WebMvcAutoConfiguration.java) 源代码或许更多详细信息。

## 76.5 Handling Multipart File Uploads

Spring Boot embraces the Servlet 3 `javax.servlet.http.Part` API to support uploading files. By default, Spring Boot configures Spring MVC with a maximum size of 1MB per file and a maximum of 10MB of file data in a single request. You may override these values, the location to which intermediate data is stored (for example, to the `/tmp` directory), and the threshold past which data is flushed to disk by using the properties exposed in the `MultipartProperties` class. For example, if you want to specify that files be unlimited, set the `spring.servlet.multipart.max-file-size` property to `-1`.
Spring Boot包含Servlet 3 `javax.servlet.http.Part` API，支持上传文件。默认，Spring Boot配置Spring MVC需要单次请求每个文件最小1MB，最大10MB的文件数据。在你想要使用Spring MVC controller handler方式接收multipart encoded文件数据时，多部分的支持是很有用的， 该数据是作为`MultipartFile`类型的`@RequestParam`-annotated 参数。

查看 [MultipartAutoConfiguration](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/servlet/WebMvcAutoConfiguration.java)源获取更多细节。

## 76.6 Switch Off the Spring MVC DispatcherServlet

Spring Boot wants to serve all content from the root of your application (`/`) down. If you would rather map your own servlet to that URL, you can do it. However, you may lose some of the other Boot MVC features. To add your own servlet and map it to the root resource, declare a `@Bean `of type `Servlet` and give it the special bean name, `dispatcherServlet`. (You can also create a bean of a different type with that name if you want to switch it off and not replace it.)
Spring Boot希望能为来自于root of your application (`/`) down所有内容提供服务。如果你更倾向于定位自己的servlet到URL中，你就可以这样做了。然而，你可能会丢失一些其他的Boot MVC features。添加你自己的servlet并将其定位到root resource，可以声明一个 `Servlet` 类型的`@Bean `，并给其一个特殊的bean name-`dispatcherServlet`。(你也可以使用那个名字创建一个不同类型的bean，如果你想要将其关闭但并不想替代它。）

## 76.7 Switch off the Default MVC Configuration

最简单的对MVC configuration采取完全控制的方式是使用`@EnableWebMvc`注解提供你自己的 `@Configuration` 。这样做可以使所有的MVC configuration都掌控在自己手中。

## 76.8 Customize ViewResolvers

 There are many implementations of `ViewResolver` to choose from, and Spring on its own is not opinionated about which ones you should use. Spring Boot, on the other hand, installs one or two for you, depending on what it finds on the classpath and in the application context. The `DispatcherServlet` uses all the resolvers it finds in the application context, trying each one in turn until it gets a result, so, if you add your own, you have to be aware of the order and in which position your resolver is added.
`ViewResolver`是Spring MVC的核心部件，将view names传送到`@Controller`来实际`View` implementations。注意，`ViewResolvers`主要用于UI应用，而非REST-style services (`View`不用来render `@ResponseBody`)。有很多`ViewResolver` implementations从中进行选择，并且Spring中，对于你自己应当使用哪一个不是可选择的。

`WebMvcAutoConfiguration` 添加下列的`ViewResolvers`到你的程序中：

-`InternalResourceViewResolver` 称作 ‘defaultViewResolver’。这个通过使用`DefaultServlet` (包括静态resources以及JSP pages)来定位可以被rendered的physical resources。在servlet context中，它对view name添加前缀及后缀，并在该path下查找physical resource(缺省值都为空但是对于`spring.mvc.view.prefix` 和 `spring.mvc.view.suffix`的外部配置是可用的。)你可以通过提供相同形式的bean来将其覆盖。
- `BeanNameViewResolver`称作 ‘beanNameViewResolver’。在view resolver链中它是很有用的一个，并能挑选任何使用同样名称作为`View`被解析的beans。它不不要覆写或替代。
-  `ContentNegotiatingViewResolver`叫做‘viewResolver’ 只有在具有实际的`View` present类型的bean时才会被添加。这是一个‘master’ resolver，代表所有其他的并尝试找到客户端发送的‘Accept’ HTTP header 的匹配。 [blog about `ContentNegotiatingViewResolver`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/servlet/WebMvcAutoConfiguration.java) 很有用。可以通过定义一个叫做‘viewResolver’的bean来关闭自动配置的`ContentNegotiatingViewResolver`。
- 如果你使用Thymeleaf，就有一个`ThymeleafViewResolver`叫做‘thymeleafViewResolver’。它是通过使用前缀及后缀来包围？view name来查找resources。前缀是`spring.thymeleaf.prefix`，后缀是`spring.thymeleaf.suffix`。前后缀的缺省值分别是‘classpath:/templates/’和 ‘.html’。你可以通过提供 同样名字的bean来覆写 override `ThymeleafViewResolver`。
- 如果你使用FreeMarker，就有`FreeMarkerViewResolver`称作‘freeMarkerViewResolver’。它在loader path中查找resources(具体为`spring.freemarker.templateLoaderPath`，缺省值是‘classpath:/templates/’)，也是在view name上使用前后缀。前缀是`spring.freemarker.prefix`，后缀是`spring.freemarker.suffix`前后缀的缺省值分别是empty和‘.ftl’。你可以通过提供同样名字的bean来覆写`FreeMarkerViewResolver`。
- 如果使用Groovy templates (实际上，如果 `groovy-templates`在classpath中)，就是 `GroovyMarkupViewResolver`称作‘groovyMarkupViewResolver’。它是在loader path中，通过在view name上添加前后缀来查看resources(分别是`spring.groovy.template.prefix` 和 `spring.groovy.template.suffix`)。前后缀的缺省值分别是‘classpath:/templates/’和‘.tpl’。可以通过提供同样名称的bean来覆写`GroovyMarkupViewResolver`。

更详细内容查阅

- [`WebMvcAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/servlet/WebMvcAutoConfiguration.java)
- [`ThymeleafAutoConfiguration` ](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/thymeleaf/ThymeleafAutoConfiguration.java)
- [`FreeMarkerAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/groovy/template/GroovyTemplateAutoConfiguration.java)
- [`GroovyTemplateAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/master/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/groovy/template/GroovyTemplateAutoConfiguration.java)

#77. HTTP Clients
Spring Boot提供很多为HTTP clients工作的starters。本节回答了与其使用相关的问题。

## 77.1 Configure RestTemplate to Use a Proxy
如[Section 33.1, “RestTemplate Customization”](https://docs.spring.io/spring-boot/docs/2.1.0.BUILD-SNAPSHOT/reference/htmlsingle/#howto-embedded-web-servers)所述，可以使用`RestTemplateCustomizer` with `RestTemplateBuilder` 来编译自定义的`RestTemplate`。这是创建`RestTemplate` configured来使用proxy的推荐方式。

proxy configuration的额外内容是依赖于使用的underlying client request factory。下列例子用`HttpClient` 配置了`HttpComponentsClientRequestFactory`，`HttpClient`对除`192.168.0.5`外所有的hosts使用proxy：

```
static class ProxyCustomizer implements RestTemplateCustomizer {

	@Override
	public void customize(RestTemplate restTemplate) {
		HttpHost proxy = new HttpHost("proxy.example.com");
		HttpClient httpClient = HttpClientBuilder.create()
				.setRoutePlanner(new DefaultProxyRoutePlanner(proxy) {

					@Override
					public HttpHost determineProxy(HttpHost target,
							HttpRequest request, HttpContext context)
							throws HttpException {
						if (target.getHostName().equals("192.168.0.5")) {
							return null;
						}
						return super.determineProxy(target, request, context);
					}

				}).build();
		restTemplate.setRequestFactory(
				new HttpComponentsClientHttpRequestFactory(httpClient));
	}

}
```
#78. Logging
Spring Boot没有强制mandatory logging dependency，除了Commons Logging API，它一般是由Spring Framework’s `spring-jcl` module提供。使用[Logback](https://logback.qos.ch/)，你需要在 classpath中include它及`spring-jcl` 。最简单的方式是使用starters，它完全依赖于`spring-boot-starter-logging`。对于一个web application，你只需要`spring-boot-starter-web`，因为它依赖于logging starter。如果使用Maven，下列dependency会为你添加logging：

```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>
```
Spring Boot有`LoggingSystem`抽象概念？ abstraction，即尝试基于classpath内容来配置logging。如果Logback可用，它就是首选。

如果要logging你要所需的唯一改变，那就设置多种水平的多种loggers，你可以在`application.properties`中使用"logging.level"前缀来实现。如下所示：

```
logging.level.org.springframework.web=DEBUG
logging.level.org.hibernate=ERROR
```
 
也可以使用"logging.file"来设置写log的文件的位置(除操纵台？？外（console）)。
在logging system中配置更多fine-grained设置，需要使用`LoggingSystem`所支持的本地配置模式。默认，Spring Boot为系统从它的缺省location中挑选本地配置（例如`classpath:logback.xml` for Logback），不过你可以通过使用"logging.config"来 property设置配置文件的location。

# 78.1 Configure Logback for Logging

如果将一个`logback.xml`置于classpath的底部？root，就会从中进行挑选（或者从 `logback-spring.xml`中，利用Boot提供的模板templating features)。

```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
	<include resource="org/springframework/boot/logging/logback/base.xml"/>
	<logger name="org.springframework.web" level="DEBUG"/>
</configuration>
```

如果在spring-boot jar中查看`base.xml`，可以发现它使用了一些有用的System properties ，这些是由LoggingSystem为你创建的：

- `${PID}`: 当前process ID.
- `${LOG_FILE}`: 判断是否`logging.file`被设置进Boot’s external configuration。
- `${LOG_PATH}`: 判断`logging.path` (代表log files所在的 directory） 是否设置在Boot’s external configuration.
- `${LOG_EXCEPTION_CONVERSION_WORD}`: 判断是否`logging.exception-conversion-word `设置在Boot’s external configuration。

Spring Boot也可以通过使用custom Logback converter在console中提供一些很好的ANSI color terminal 输出(不是在log file中)。查看默认的`base.xml` configuration获取更详细信息。
 
如果Groovy在classpath上，就也可以使用`logback.groovy` 配置Logback。该设置具有优先权。

### 78.1.1 Configure Logback for File-only Output

如果想要使console logging失效，并将输出只写到一个文件中，你需要一个自定义的`logback-spring.xml` ，它可以输入`file-appender.xml`但不能输入 `console-appender.xml`，如下所示：
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
	<include resource="org/springframework/boot/logging/logback/defaults.xml" />
	<property name="LOG_FILE" value="${LOG_FILE:-${LOG_PATH:-${LOG_TEMP:-${java.io.tmpdir:-/tmp}}/}spring.log}"/>
	<include resource="org/springframework/boot/logging/logback/file-appender.xml" />
	<root level="INFO">
		<appender-ref ref="FILE" />
	</root>
</configuration>
```
 
你也需要添加`logging.file`到你的 `application.properties`中，如下所示：

```
logging.file=myapplication.log
```

## 78.2 Configure Log4j for Logging
Spring Boot supports  for  if it is on the classpath. If you use the for , you have to . If you do not use the 
Spring Boot支持[Log4j 2](https://logging.apache.org/log4j/2.x/)进行logging configuration，如果其位于classpath。如果你为assembling dependencies使用starters，你必须exclude Logback并include log4j 2作为替代。如果你不使用starters，除了Log4j 2就要提供（至少）`spring-jcl`.

最简单的path可能就是starters，即使它需要一些jiggling with excludes。下面介绍的是如何在Maven 中设置starters：
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter</artifactId>
	<exclusions>
		<exclusion>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-logging</artifactId>
		</exclusion>
	</exclusions>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-log4j2</artifactId>
</dependency>
```

[Note]
 Log4j starters集中了common logging requirements的 dependencies(例如使用`java.util.logging`获得Tomcat但是使用Log4j 2配置输出）。查看[Actuator Log4j 2](https://logging.apache.org/log4j/2.x/)示例。 

[Note]
 
为保证使用`java.util.logging`执行的debug logging是按路线发送到Log4j 2，要通过设置`java.util.logging.manager` system property到`org.apache.logging.log4j.jul.LogManager`中来配置它的 [JDK logging adapter](https://logging.apache.org/log4j/2.0/log4j-jul/index.html)。

### 78.2.1 Use YAML or JSON to Configure Log4j 2

除了它本身的默认XML configuration format， Log4j 2 也支持YAML和JSON 配置文件。要使用可选择的配置文件形式来配置Log4j 2，需要添加appropriate dependencies到 classpath中，并你的配置文件的命名与你选择的文件格式相匹配，如下所示：

**Format	Dependencies**	**File names**
YAML

`com.fasterxml.jackson.core:jackson-databind `
`com.fasterxml.jackson.dataformat:jackson-dataformat-yaml`

`log4j2.yaml log4j2.yml`

JSON

`com.fasterxml.jackson.core:jackson-databind`

`log4j2.json log4j2.jsn`