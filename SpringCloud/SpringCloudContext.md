# Spring Cloud Context

## 一、Bootstrap应用上下文
Spring Cloud应用通过创建一个bootstrap上下文生效，这是主应用的父上下文。主要负责加载外部来源的配置属性，同时解析本地外部配置文件中的属性。
引导上下文（Bootstrap Context）和主应用的上下文共享同一个`Environment`，这是任何Spring应用都会使用的外部属性来源。bootstrap属性有很高的优先权，默认不会被本地配置覆盖。  
引导上下文与主应用上下文配置外部配置的约定不同，应使用`bootstrap.yml`代替`application.yml`保持bootstrap和main上下文的外部属性分离。  
通过设置`spring.cloud.bootstrap.enabled=false`可完全禁掉bootstrap处理。

## 二、应用上下文层级
通过`SpringAppliction`或`SpringApplicationBuilder`构建了一个应用上下文时，引导上下文会作为该上下文的父级上下文添加到应用中。
在Spring中，子上下文会继承父上下文的属性，所以与没有Spring Cloud Config的上下文相比，应用的上下文会包含额外的属性来源。
额外的属性来源为：
+ bootstrap
 如果在引导上下文中存在PropertySourceLocator且包含非空值时，会创建一个高优先级的CompositePropertySource。
 **bootstrap属性拥有高优先级**
+ applictionCofig [classpath:bootstrap.yml]：
 bootstrap.yml文件中的属性会用于配置引导上下文，之后会被添加到子上下文。这些属性比application.yml中的属性优先级低，
 也比Spring Boot应用创建过程中添加到子上下文的其他属性源的优先级低。  
 **低优先级，会被子上下文覆盖，可用于设置默认值。**  
 
## 三、修改Bootstrap属性的位置
 通过`spring.cloud.bootstrap.name`(默认bootstrap)或`spring.cloud.bootstrap.location`(默认空)指定bootstrap.yml的位置。  
 
## 四、覆盖远程属性值
 引导上下文中的属性通常是远程的且不可被本地覆盖，除非通过命令行覆盖。如果要通过本地系统属性或配置文件覆盖远程的属性，远程的属性配置需要为：
 ```
 spring.cloud.config.allowOverride=true     # 必须在远程设置
 spring.cloud.config.overrideNone=true      # 使用所有本地属性配置覆盖远程
 spring.cloud.config.overrideSystemProperties=false     # 仅使用System属性和环境变量覆盖远程设置
 ```
  
## 五、自定义Bootstrap配置
 通过在`/META/spring.factories`文件中的`org.springframework.cloud.bootstrap.BootstrapConfiguration`下可定义Bootstrap启动的文件。
 值是用于创建上下文的通过逗号分割的`@Configuration`类列表。  
 添加自定义BootstrapConfiguration时，避免这些类被主应用扫描到。  
 引导过程在向`SpringApplication`实例注入初始化器（initializer）后即结束，这些初始化器就是SpringBoot正常的启动序列。
 首先，bootstrap会根据`spring.factories`中发现的类创建；然后，所有`ApplicationInitializer`的`@Bean`会在主程序启动前添加。
 
## 六、自定义Bootstrap属性源
 引导处理过程添加的外部属性的默认属性源是Config服务器，通过`spring.factories`添加到引导上下文中的`PropertySourceLocator`的bean可添加数据源。
 `PropertySourceLocator`中`locate(Environment environment)`方法的参数`Environment`就是`ApplicationContext`将要创建的，
 也是我们要添加额外属性来源的。这个`Environment`已经添加了SpringBoot提供的属性源。

## 七、Environment变更
 应用会监听`EnvironmentChangeEvent`并对变化做出应对(`ApplicationListener`可通过`@Bean`添加到监听中)。
 当`EnvironmentChangeEvent`发生时会产生变化的key-value列表，应用会把他们用于：  
 + 将上下文中包含的所有`@ConfigurationProperties`重新绑定
 + 为`logging.level.*`中的所有属性设置logger水平  
 
 默认地，ConfigClient不会检测`Environment`的变化，通常也不会推荐这种方式检测变化。
 更好的方式是使用广播方式把`EnvironmentChangeEvent`通知到所有的实例。


[返回](https://github.com/McHeat/Note/blob/master/SpringCloud/SpringCloud.md)