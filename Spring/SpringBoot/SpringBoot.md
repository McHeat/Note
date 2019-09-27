# Spring Boot

## 一、 构建（Build）
 推荐使用支持依赖管理及使用maven中心库的构建工具，如Maven和Gradle。  
 + SpringBoot的每个发行版都会提供支持的依赖清单，示例如下：
 
    ```
    org.springframework.boot:spring-boot-dependencies:1.5.7.RELEASE
    ```
### 1. Maven构建
#### 1.1 通过继承starter parent
 此方法可使用starter的依赖管理和插件管理
 ```xml
    <!-- Inherit defaults from Spring Boot -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.7.RELEASE</version>
    </parent>
 ```
 通过这种设置，你可以通过在自己的项目中重写属性的方式替换某个依赖
 ```
    <!-- 替换版本 -->
    <properties>
        <spring-data-releasetrain.version>Fowler-SR2</spring-data-releasetrain.version>
    </properties>
 ```
#### 1.2 通过dependencies管理依赖  
 此方法可使用dependencies的依赖管理，但是无法使用插件管理。
 ```xml
    <dependencyManagement>                                             
        <dependencies>                                                 
            <dependency>                                               
                <!-- Import dependency management from Spring Boot --> 
                <groupId>org.springframework.boot</groupId>            
                <artifactId>spring-boot-dependencies</artifactId>      
                <version>1.5.7.RELEASE</version>                       
                <type>pom</type>                                       
                <scope>import</scope>     <!-- 使用import -->            
            </dependency>                                              
        </dependencies>                                                
    </dependencyManagement>                                            
 ```
 使用这种设置，你将无法像之前描述的一样通过重写属性方式替换某个依赖。为了达到同样效果，你需要在`dependencyManagement`标签下`spring-boot-dependecies`实体**之前**添加对应的dependency实体。
 例如，为了升级到SpringData的其他发布版，可以在`pom.xml`中添加下列元素：  
 
```xml
<dependencyManagement>
	<dependencies>
		<!-- Override Spring Data release train provided by Spring Boot -->
		<dependency>
			<groupId>org.springframework.data</groupId>
			<artifactId>spring-data-releasetrain</artifactId>
			<version>Fowler-SR2</version>
			<type>pom</type>
			<scope>import</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-dependencies</artifactId>
			<version>2.0.3.RELEASE</version>
			<type>pom</type>
			<scope>import</scope>
		</dependency>
	</dependencies>
</dependencyManagement>
```
 
#### 1.3 修改Java版本
 `spring-boot-starter-parent`选择了相当保守的Java适配性。可通过`java.version`属性使用其他版本：
 ```xml
 <properties>
     <java.version>1.8</java.version>
 </properties>
 ``` 
#### 1.4 使用Spring Boot Maven插件
 Spring Boot包含了一个用于打包可执行jar的Maven插件。通过在<plugins>标签下添加来使用：
 ```xml
 <build>
     <plugins>
         <plugin>
             <groupId>org.springframework.boot</groupId>
             <artifactId>spring-boot-maven-plugin</artifactId>
         </plugin>
     </plugins>
 </build>
 ```
 
### 2. Gradle构建
 不同于Maven，Gradle中不能通过导入parent来共享配置，可以通过在`dependencies`部分中直接导入starters添加依赖：
 ```
 repositories {
     jcenter()
 }
 
 dependencies {
     compile("org.springframework.boot:spring-boot-starter-web:1.5.10.RELEASE")
 }
 ```
`spring-boot-gradle-plugin`提供了创建可执行jar和通过源码运行项目的task。同时也提供了dependency management，这允许你忽略Spring Boot管理的依赖项的版本。
```
plugins {
    id 'org.springframework.boot' version '1.5.10.RELEASE'
    id 'java'
}


repositories {
    jcenter()
}

dependencies {
    compile("org.springframework.boot:spring-boot-starter-web")
    testCompile("org.springframework.boot:spring-boot-starter-test")
}
```

## 二、Configuration类
+ SpringBoot提倡使用java-based配置  
  通常，定义了main方法的类也是主要`@Configuartion`的首选。
+ 引入更多的configuration类  
  通过`@Import`注解可引入额外的configuration类。  
  可使用`@ComponentScan`来自动注册所有的Spring组件，包括`@Configuration`类。
+ 引入XML配置  
  通过`@ImportResource`注解来加载XML配置文件。

## 三、自动配置
+ SpringBoot的自动配置会尝试根据已添加的jar依赖自动配置Spring应用。  
  通过在其中一个`@Configuartion`类上添加`@EnableAutoConfiguration`或`@SpringBootApplication`注解可开启自动配置。
+ 逐步取代自动配置  
  自动配置是非侵入式的。可通过自定义配置来取代自动配置中的特定部分。  
  在启动应用时添加--debug可查看当前正在使用的自动配置。
+ 禁用特定自动配置  
  通过`@EnableAutoConfiguration`设置exclude的值可禁用自动配置。  
  通过`spring.autoconfigure.exclude`设置排除自动配置的类。

## 四、开发者工具  
添加`spring-boot-devtools`模块:  
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```
    
## 五、SpringApplication类
+ SpringApplication类提供了通过main()方法引导启动Spring应用的简便方法。  
  绝大多数情况，可直接使用SpringApplication.run()静态方法。
+ 启动失败：  
  当应用启动失败时，注册的FailureAnalyzers会提供专用错误信息和修复问题的详细方法。  
  如果无法处理异常时，可通过展示完整的auto-configuration报告来查看问题。`--debug`
+ 自定义Banner  
  1.通过在classpath下添加banner.txt文件或设置`banner.location`指定文件可修改启动时打印的banner。通过`banner.charset`可指定文件的编码格式。  
  2.可添加banner.gif、banner.jpg、banner.png图片文件或设置banner.image.location属性来使用图片。  
  3.可使用`spring.main.banner-mode`属性设置使用System.out(设为console)或配置的log(设为log)或不打印(设为off)。
### 1. 配置SpringApplication  
+ 当SpringApplication的默认行为不满足需求时，可创建并配置本地实例。  
    ```java
    SpringApplication app = new SpringApplication();                      
    app.setBannerMode(Banner.Mode.OFF);                                   
    app.run(args);                                                        
    ```
+ 通过`application.properties`文件也可配置SpringApplication。

### 2. 流式构造API
当需要创建一个ApplicationContext层级架构或偏向于使用流式API时，可考虑使用`SpringApplicationBuilder`来构建。SpringApplicationBuilder允许链式调用方法，并提供了parent和child方法帮助建立层级结构。  
当使用SpringApplicationBuilder创建ApplicationContext层级结构时，存在一些限制。如：
+ Web组件必须放置在child上下文中；
+ parent和child上下文中Environment是相同的。等等~

### 3. Application Events和监听器
除了Spring框架的常用事件ContextRefreshedEvent外，SpringApplication新增了一些额外的应用事件。
> 有些event事件的触发事件可能在ApplicationContext创建之前，这些事件无法通过@Bean注册监听器。这些事件可通过`SpringApplication.addListners(...)`或`SpringApplicationBuilder.listeners(...)`方法注册监听器；或通过在`META-INF/spring.factories`文件中添加`org.springframework.context.ApplicationListener=com.example.MyListener`自动注册监听器。

应用级事件发送的顺序如下：  
+ `ApplicationStartingEvent`：在run开始时发送，在除监听器和初始程序注册之外的其他所有操作之前。（监听器未获取到消息？）
+ `ApplicationEnvironmentPreparedEvent`：context未创建，但将用到的Environment已确定。
+ `ApplicationPreparedEvent`：在refresh开始之前，此时bean定义已加载完成。
+ `ApplicationStartedEvent`：上下文已刷新，但任何应用或命令行都未调用。
+ `ApplicationReadyEvent`：在refresh后且所有相关回调已处理完成后发送，表示应用已可接收请求。
+ `ApplicationFailedEvent`：启动抛出异常。  

应用级事件使用了Spring框架的事件发布机制，这种机制会将发送给子上下文监听器的事件同时发送到父上下文的监听器。因此，当使用层级结构的SpringApplication实例时，一个监听器可能多次收到同一类型的应用级事件。为了确保监听器能够区分来自不同上下文的事件，监听器应注入对应的上下文并与事件包含的上下文进行比较（可通过实现`ApplicationContextAware`或`@Autowired`注入ApplicationContext）。

### 4. Web Environment
`SpringApplication`会创建合适类型的`ApplicationContext`，决定`WebApplicationType`的算法简单如下：  
+ 存在Spring MVC时，会选择`AnnotationConfigServletWebServerApplicationContext`上下文；
+ 不存在Spring MVC但存在Spring WebFlux时，会选择`AnnotationConfigReactiveWebServerApplicationContext`上下文；
+ 其他情况下，使用`AnnotationConfigApplicationContext`。  

可通过setWebApplicationType(WebApplicationType)设置是否使用web environment。

### 5. 使用应用的arguments
如果项目中需要使用启动应用过程中传递给`SpringApplication.run(...)`的参数，可注入`org.springframework.boot.ApplicationArguments`类对应的bean。`ApplicationArguments`接口既可以通过`String[] getSourceArgs()`获取原始的参数，也可以获取格式化的option或non-option参数。  

> Spring Boot同时向Spring自身的`Environment`注册了`CommandLinePropertySource`，因此单个应用级参数可以通过`@Value`注释注入到对应的属性中。

### 6. 使用ApplicationRunner或CommandLineRunner
如果SpringApplication启动后需要立即执行某些代码，可实现`ApplicationRunner`或`CommandLineRunner`接口。这两个接口的`run(...)`方法会在`SpringApplication.run(...)`即将完成前调用。如果存在多个且需要按照一定的顺序执行，可实现`org.springframework.core.Ordered`接口或使用`org.springframework.core.annotation.Order`注解。  

### 7. 应用退出
每个SpringApplication应用都会向JVM注册关闭钩子，以确保ApplcationContext在退出时能够优雅地关闭。所有Spring的标准生命周期回调方法都会被调用，比如`DisposableBean`接口或`@PreDestroy`注解。  
如果bean需要在执行`SpringApplication.exit()`时返回指定的exit码，可以实现`org.springframework.boot.ExitCodeGenerator`。返回的exit码会传递给`System.exit()`作为返回码。  
exception可实现ExitCodeGenerator接口。当遇到异常时，SpringBoot会返回这个exit码。
### 8. Admin特性
通过设置`spring.application.admin.enabled`属性，可开启相关管理特性。这会暴露MBeanServer平台的`SpringApplicationAdminMXBean`，从而可以远程管理Spring Boot应用。  
    
配置外部化
    |-- 可使用properties文件、yaml文件、环境变量和命令行参数使配置外部化。
    |-- Property值的使用方法：
    |       1.可通过@Value注解直接注入到bean中，
    |       2.可通过spring的Environment抽象类使用，
    |       3.可通过@ConfigurationProperties绑定到结构化对象
    |-- PropertySource的优先级：
    |   |-- home文件目录里的devtools全局设置properties（~/.spring-boot-devtools.properties）
    |   |-- 测试类的@TestPropertySource注解
    |   |-- 测试类的@SpringBootTest#properties注解属性
    |   |-- 命令行参数
    |   |-- 从SPRING_APPLICATION_JSON中读取的properties（环境变量或系统属性）
    |   |-- ServletConfig的初始化参数
    |   |-- ServletContext的初始化参数
    |   |-- 从java:comp/env中获取的JNDI参数
    |   |-- Java系统参数System.getProperties()
    |   |-- 操作系统environment参数
    |   |-- A RandomValuePropertySource that only has properties in random.*
    |   |-- 已打包的jar外的profile指定的application properties（application-{profile}.properties|yaml）
    |   |-- 已打包的jar内的profile指定的application properties（application-{profile}.properties|yaml）
    |   |-- 已打包的jar外的application properties（application.properties|yaml）
    |   |-- 已打包的jar内的application properties（application.properties|yaml）
    |   |-- @Configuration类上的@PropertySource注解
    |   |-- 默认properies（通过SpringApplication.setDefaultProperties指定） 
    |-- RandomValuePropertySource
    |   |-- 用于注入随机值，可产生integer、long、uuid或string等。
    |-- Application Property文件
    |   |-- file:./config/ -> file:./ -> classpath:/config/ -> classpath:/
    |   |-- spring.config.name指定配置文件的基本名称
    |   |-- spring.config.location指定配置文件的路径
    |-- Profile-specific属性
    |   |-- 通过约定名称application-{profile}.properties定义profile-specific属性文件。
    |   |-- spring.profiles.active属性指定profile
    |   |-- 通过spring.config.location指定文件时，这些文件的profile-specific文件将无法使用。尽量使用指定目录。
    |-- 属性的占位符
    |   |-- application.properties文件中的值会通过存在的Environment过滤。可使用${}占位。
    |-- 使用YAML代替Properties
    |   |-- YamlPropertiesFactoryBean会加载YAML为Properties，而YamlMapFactoryBean会加载YAML为Map。
    |   |-- YamlPropertySourceLoader类将YAML转为Spring的Environment中的PropertySource。
    |   |-- 可在同一个文件中使用spring.profiles定义多个profile-specific的YAML文档
    |   |   server:
    |   |     address: 192.168.1.100
    |   |   ---
    |   |   spring:
    |   |     profiles: development
    |   |   server:
    |   |     address: 127.0.0.1
    |   |   ---
    |   |   spring:
    |   |     profiles: production
    |   |   server:
    |   |     address: 192.168.1.120
    |   |-- YAML无法使用@PropertySource注解加载。
    |-- 类型安全的配置属性
    |   |-- 使用@Value("${property}")注解注入配置属性有时会很繁杂，尤其是层级结构时。
    |   |-- 通过@ConfigurationProperties(....)注入类型化的bean中
    |   |       当使用Collection类型时，初始化时设置为final关键字确保是不可改变的。
    |   |       需在@Configuration类上添加@EnableConfigurationProperties(XXX.class)
    |   |-- 第三方配置
    |   |       @CongfigurationProperties可用于public @Bean方法上。
    |   |       这在绑定属性到第三方组件时极为有效。
    |   |-- 宽松绑定：
    |   |       SpringBoot制定了一些宽松规则来绑定Environment属性到@ConfigurationProperties的bean。
    |   |       Environment属性名和bean的属性名不必完全匹配。如短线分隔首字母，大写的环境属性
    |   |-- 属性转换
    |   |       SpringBoot会尝试将属性强制转为@ConfigurationProperties类的正确类型
    |   |       自定义类型转换：
    |   |           1.提供id为conversionSservice的ConversionService类型bean
    |   |           2.通过CustomEditorConfigurer类型的bean自定义属性editor
    |   |           3.通过注解为@ConfigurationPropertiesBinding的bean定义来自定义Converters
    |   |-- 可使用JSR-303实现@ConfigurationProperties类的校验
    
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















