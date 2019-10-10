# Spring Boot

Logging
    |-- SpringBoot的内部logging使用CommonLogging，但是底层的log实现是开放的。
    |-- 如果终端支持ANSI，可使用彩色输出来提高可读性。设置spring.output.ansi.enabled
    |       %clr(%5p)
    |-- 文件输出
    |   |-- SpringBoot默认只会输出日志到控制台而不写入log文件。
    |   |-- 可通过logging.file或logging.path属性设置
    |-- log等级：logging.level.*=LEVEL  LEVEL可取值TRACE、DEBUG、INFO、WARN、ERROR、FATAL、OFF
    |-- 自定义log配置：
    |   |-- SpringBoot的各种日志系统可通过添加对应的jar库及定义合适的配置文件或logging.config参数来激活。
    |   |-- 日志在ApplicationContext创建前被初始化，不可通过@Configuration文件读取的@PropertySource控制。
    |   |   Logback --> logback-spring.xml, logback-spring.groovy, logback.xml, logback.groovy
    |   |   Log4j2  --> log4j2-spring.xml, log4j2.xml
    |   |   JDK     --> logging.properties
    |-- Logback扩展
    |   |-- <springProfile>标签可根据激活的Spring profile选择包括或排除配置块。
    |   |-- <springProperty>标签可从Spring的Environment中提取属性供Lobback使用。
    |   |       <springProperty scope="context" name="fluentHost" source="myapp.fluentd.host" 
    |   |           defaultValue="localhost"/>
    
    
开发web应用
    |-- Spring Web MVC
    |   |-- 自动配置
    |   |       ContentNegotiatingViewResolver和BeanNameViewResolver类型bean的导入
    |   |       静态资源服务的支持，包括对war的支持
    |   |       Converter、GenericConverter和Formatter的自动注册
    |   |       对HttpMessageConverters的支持
    |   |       自动注册MessageCodesResolver
    |   |       静态index.html支持
    |   |       自定义Favicon支持
    |   |       自动使用ConfigurableWebBindingInitializer的bean
    |   |-- HttpMessageConverters
    |   |   |-- SpringMVC使用HttpMessageConverter接口转化HTTP的请求和响应。
    |   |   |       Object会自动转化为JSON或XML。String默认使用UTF-8进行编码。
    |   |   |       可通过HttpMessageConverters类添加或自定义转换器。
    |   |   |       上下文中的任何HttpMessageConverter类型的bean都会自动添加到转换器列表。
    |   |-- 自定义Json序列化和反序列化
    |   |   |-- Spring Boot提供了可选的@JsonComponent注解用于自定义序列化工具。
    |   |   |       可以在JsonSerializer和JsonDeserializer实现类上添加@JsonComponent实现。
    |   |   |       可以在包含内部类serializers/deserializers的类上使用@JsonComponent注解。
    |   |   |       SpringBoot提供了JsonObjectSerializer和JsonObjectDeserializer基类支持。
    |   |-- MessageCodesResolver
    |   |-- 静态内容
    |   |   |-- SpringBoot默认提供静态内容支持位置:
    |   |   |       1.classpath下的/static或/public或/resources或/META-INF/resources
    |   |   |       2.ServletContext的根路径
    |   |   |-- SpringBoot使用ResourceHttpRequestHandler来服务静态内容。
    |   |   |       可通过添加WebMvcConfigurerAdapter并重写addResourceHandlers方法修改行为。
    |   |   |-- resources默认会映射到/**，可通过spring.mvc.static-path-pattern来调整。
    |   |   |       可通过spring.resources.static-locations自定义静态资源的位置。
    |   |   |-- 如果应用被打包为jar时，不要使用src/main/webapp文件夹。















