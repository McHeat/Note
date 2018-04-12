
  

## 1. Service Discovery: Eureka Clients ##

Service Discovery 是微服务架构（a microservice based architecture）的一个关键原则。尝试手动配置每个客户端或或某种约定 （some form of convention）是非常困难，也是不稳定的（brittle）  Eureka是Netflix Service Discovery的服务器与终端（Server and Client0. Eureka能够通过配置和扩展成更高的可用性，每个服务器的注册状态复制给其他服务器。

## 1.1 How to Include Eureka Client ##
通过使用 ` org.springframework.cloud`群语句开头以及artifact id` spring-cloud-starter-netflix-eureka-client`. 查看 [Spring Cloud Project page](https://projects.spring.io/spring-cloud/)来学习更多如何使用当前的Spring Cloud Release Train来设置编译系统。

## 1.2 Registering with Eureka ##
当有客户端为 Eureka登记时, 需要提供自身的元数据（meta-data） ，例如：host and port, health indicator URL, home page等。 Eureka从每个服务器的实例（instance）接收 heartbeat messages 。 如果heartbeat在一个配置时间内（configurable timetable）获取失败（fails），此实例会被从registry上移除。

Example eureka client:
    
    @Configuration
    @ComponentScan
    @EnableAutoConfiguration
    @RestController
    public class Application {
    
    @RequestMapping("/")
    public String home() {
    	return "Hello world";
    }
    
    public static void main(String[] args) {
    	new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
    
    }
(i.e. utterly normal Spring Boot app). classpath中使用  `spring-cloud-starter-netflix-eureka-client` 能使你的程序自动注册到Eureka Server. 要求配置（Configuration)位于Eureka server.

 Example:

**application.yml. **

    eureka:
      client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/

"defaultZone" 是一句神奇的字符串回退值（string fallback value），为任何不能传递优先权（express a preference (i.e. it’s a useful default)）提供服务器URL

 `Environment`的缺省程序名(service ID), 虚拟主机（virtual host) 和非保护端口 （non-secure port）分别是 `${spring.application.name}`, `${spring.application.name}` and `${server.port} `

在classpath中使用 `spring-cloud-starter-netflix-eureka-client` 可以使app进入（into both ）Eureka "instance" (i.e. it registers itself)和"client" (i.e. it can query the registry to locate other services). 此instance behaviour由`eureka.instance.* `配置关键字（configuration keys）驱动的, 如果能确认程序具有` spring.application.name` (Eureka service ID, or VIP是默认的)来保证缺省值 .

查看 [EurekaInstanceConfigBean](https://github.com/spring-cloud/spring-cloud-netflix/blob/master/spring-cloud-netflix-eureka-client/src/main/java/org/springframework/cloud/netflix/eureka/EurekaInstanceConfigBean.java) 和 [EurekaClientConfigBean](https://github.com/spring-cloud/spring-cloud-netflix/blob/master/spring-cloud-netflix-eureka-client/src/main/java/org/springframework/cloud/netflix/eureka/EurekaClientConfigBean.java) 以获取更详细的信息。

禁止Eureka Discovery Client可设置 `eureka.client.enabled`为 `false`.

## 1.3 Authenticating with the Eureka Server ##
## 1.3  Eureka Server验证 ##
如果其中 `eureka.client.serviceUrl.defaultZone`的网址 URLs 具有凭证嵌入式 (credentials embedded),HTTP基本验证会自动添加到你的 eureka client，(curl style, 例如 [http://user:password@localhost:8761/eureka](http://user:password@localhost:8761/eureka)). 更复杂的需求可以创建   `DiscoveryClientOptionalArgs`类型 的`@Bean` 以及插入`ClientFilter` 实例, 所有这些都可以应用于从client 到server的调用（calls）.

[Note]
由于Eureka的限制， 支持 per-server basic auth credentials不现实的 , 因此只有第一次设置有用。

## 1.4 Status Page and Health Indicator ##
 Eureka实例的status page和 health indicators分别默认为"/info" 和 "/health" ,是Spring Boot Actuator application 里有用端点（useful endpoints）的默认位置（default locations）. 你需要替换这些, 即使Actuator application 使用的是a non-default context 、servlet path的(e.g. `server.servletPath=/foo`) 或者 management endpoint path (e.g. `management.contextPath=/admin`). 
Example:

**application.yml. **

    eureka:
      instance:
    statusPageUrlPath: ${management.context-path}/info
    healthCheckUrlPath: ${management.context-path}/health
上述链接显示了被客户端clients消耗掉的元数据metadata, 并且用于一些判断是否需要向程序发送请求的脚本中, 因此如果they是准确的将会非常有用。

## 1.5 Registering a Secure Application ##
## 1.5 注册一个安全的应用程序 ##
如果你希望 app能够被其他网址HTTPS连接到，可以在`EurekaInstanceConfig`设置两个flags,分别是`eureka.instance.[nonSecurePortEnabled，securePortEnabled]=[false,true]` 。这样能使Eureka publish instance information为保密通信（secure communication ）显示明确的参数 （explicit preference）. Spring Cloud DiscoveryClient可以一直返回到一个以https开头的 URI，并且Eureka (native) instance information可以有一个具有 secure health check的URL.

因为这种方式 Eureka 作用在内部, 也能为status和home page发布非安全URL，除非明确覆盖。也能够使用占位符（placeholders）来配置eureka instance urls,例如：

**application.yml. **

    eureka:
      instance:
    statusPageUrl: https://${eureka.hostname}/info
    healthCheckUrl: https://${eureka.hostname}/health
    homePageUrl: https://${eureka.hostname}/

(注意 `${eureka.hostname}` 是本机占位符（native placeholder ）只可用在Eureka的后续版本.使用Spring placeholders可以实现相同的作用，例如使用`${eureka.instance.hostName}`)

[Note]
如果你的app 是由代理服务器（proxy）运行, 并且SSL终止处（ termination）也在该代理服务器（proxy）中(例如 ，如果你作为服务运行在Cloud Foundry或其他平台) ，那么需要确保该proxy "forwarded" headers 是被拦截的并且由程序负责控制.如果精确配置'X-Forwarded-\*` headers，在Spring Boot app中的嵌入式Tomcat container可以自动实现上述功能。典型错误是：该链接被你的程序释放到自身中(错误的host, 端口或协议)。

## 1.6 Eureka’s Health Checks ##

默认的，Eureka使用client heartbeat来决定客户端是否挂起（up）。除非指定，否则Discovery Client不能按照Spring Boot Actuator传输当前的health check状态。也就意味着成功登记后的Eureka会总是 声明该程序application是 'UP' 状态. 这种行为可能被授权的Eureka health checks 警告，从而导致一直传送程序状态给 Eureka. 结果其他的每个程序都不能与in state的程序通信，从而挂起('UP').

**application.yml. **

    eureka:
      client:
    healthcheck:
      enabled: true
[Warning]
`eureka.client.healthcheck.enabled=true` z只能被设置在**application.yml**中。 给bootstrap.yml赋值会导致副作用出现,如登记过的eureka出现`UNKNOWN `状态。

若需要控制health checks, 可以考虑执行自己的 `com.netflix.appinfo.HealthCheckHandler`。

## 1.7 Eureka Metadata for Instances and Clients ##
花费一些时间来了解 Eureka metadata的工作方式是很值得的, 如此你就可以在自己的平台上做出有意的事情. hostname, IP address, port numbers, status page and health chec具有k标准元数据。这些发布在服务登记处（ service registry） 并被客户端用于与服务器直接联系。额外的元数据可附加在`eureka.instance.metadataMap`中的instance registration, 并且可被远程客户端使用, 但是一般来说不会改变客户端的行为, 除非意识到元数据的意义meaning。 下面讲述了一些Spring Cloud分配metadata map的特例

### 1.7.1 Using Eureka on Cloudfoundry ###

Cloudfoundry 具有全局路由（global router），所以相同app中所有实例有一样的hostname (其他具有相似的架构的PaaS solutions也是相同的 ). 使用Eureka并不需要栅栏（barrier）, 但是如果你使用该路由（router） (被建议的, 或强制性依赖于你当前创建的平台), 需要明确设置hostname和port numbers (secure or non-secure) ，如此才能使用路由. 你或许也希望使用实例元数据（instance metadata），那么需要区别客户端里的实例（the instances on the client） (例如定制的负载平衡器（custom load balancer)）. 默认 `eureka.instance.instanceId` 是 `vcap.application.instance_id`.  例如:

**application.yml. **

    eureka:
      instance:
    hostname: ${vcap.application.uris[0]}
    nonSecurePort: 80
根据你的 Cloudfoundry instance里规定的安全规则（security rules） ,你或许可以注册（ register） 并且使用host VM for direct service-to-service calls的IP地址. 此方案对Pivotal Web Services (PWS)中还不可用.

### 1.7.2 Using Eureka on AWS ###

如果程序计划配置给AWS cloud, 那么Eureka instance将不得不配置给 AWS aware，并且这可以通过按照如下方式定制EurekaInstanceConfigBean来实现:
    
    @Bean
    @Profile("!default")
    public EurekaInstanceConfigBean eurekaInstanceConfig(InetUtils inetUtils) {
      EurekaInstanceConfigBean b = new EurekaInstanceConfigBean(inetUtils);
      AmazonInfo info = AmazonInfo.Builder.newBuilder().autoBuild("eureka");
      b.setDataCenterInfo(info);
      return b;
    }
### 1.7.3 Changing the Eureka Instance ID ###

普通Netflix Eureka instance是需要使用等价于host name (如每个host都只有一个service)的ID来注册. Spring Cloud Eureka 提供可感测的系统默认值（sensible default），如下面所示: `${spring.cloud.client.hostname}:${spring.application.name}:${spring.application.instance_id:${server.port}}}. For example myhost:myappname:8080`.

如果提供`eureka.instance.instanceId`的唯一识别符，使用Spring Cloud可以重载系统默认值。例如:

**application.yml. **
    eureka:
      instance:
    instanceId: ${spring.application.name}:${vcap.application.instance_id:${spring.application.instance_id:${random.value}}}
使用元数据以及配置在localhost的多重服务实例, 随机值随之生效而使实例唯一（instance unique）. 在Cloudfoundry中`vcap.application.instance_id` 会被自动填充进Spring Boot 程序, 因此随机值就不必要了.

## 1.8 Using the EurekaClient ##
一旦你的app是一个可被发现客户端（discovery client），就可以用它来从Eureka Server中发现服务实例（service instances）。一种方式是 使用本地的`com.netflix.discovery.EurekaClient` (对照Spring Cloud `DiscoveryClient`)。

    @Autowired
    private EurekaClient discoveryClient;
    
    public String serviceUrl() {
    InstanceInfo instance = discoveryClient.getNextServerFromEureka("STORES", false);
    return instance.getHomePageUrl();
    }
[Tip]
不要在`@PostConstruct` method 或者`@Scheduled `method (或者任何 `ApplicationContext`还不能开始的地方)中使用`EurekaClient`  。 在 `SmartLifecycle `( `phase=0`) 中初始化因此早期可依赖另一个更高phase的 `SmartLifecycle` 获得的`EurekaClient` 

### 1.8.1 EurekaClient without Jersey ###

一般 EurekaClient使用Jersey进行HTTP通讯。如果想要避免来自于Jersey的依赖性, 可以从依赖性（dependencies）中拒绝。 Spring Cloud能够自动配置依赖Spring RestTemplate的传送客户端（transport client）。

    <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
    <exclusions>
    <exclusion>
    <groupId>com.sun.jersey</groupId>
    <artifactId>jersey-client</artifactId>
    </exclusion>
    <exclusion>
    <groupId>com.sun.jersey</groupId>
    <artifactId>jersey-core</artifactId>
    </exclusion>
    <exclusion>
    <groupId>com.sun.jersey.contribs</groupId>
    <artifactId>jersey-apache-client4</artifactId>
    </exclusion>
    </exclusions>
    </dependency>
## 1.9 Alternatives to the native Netflix EurekaClient ##
## 1.9 本地Netflix EurekaClient的可替换性 ##
不需要使用原始的Netflix `EurekaClient` ，一般在封装的分类（sort）后使用会更方便。Spring Cloud支持 [Feign](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/1.4.4.RELEASE/multi/multi_spring-cloud-feign.html) (REST client编辑器)，Spring [RestTemplate](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/1.4.4.RELEASE/multi/multi_spring-cloud-ribbon.html) 使用逻辑Eureka service identifiers (VIPs) 代替 物理的URLs。使用固定列表的物理服务器（physical servers）配置Ribbon可以简单设置 `<client>.ribbon.listOfServers`到的物理地址的comma-separated list(或hostnames), 该地址中`<client> `是客户端的ID。

也可以使用`org.springframework.cloud.client.discovery.DiscoveryClient` 给discovery clients提供简单API，此非Netflix的特性, 例.

    @Autowired
    private DiscoveryClient discoveryClient;
    
    public String serviceUrl() {
    List<ServiceInstance> list = discoveryClient.getInstances("STORES");
    if (list != null && list.size() > 0 ) {
    return list.get(0).getUri();
    }
    return null;
    }
 ## 1.10 Why is it so Slow to Register a Service? ##
## 1.10 为何Register a Service如此之慢? ##
开始一个实例也包括对注册表的周期性的heartbeat(通过 client’s serviceUrl) ，默认为30秒。除非instance, the server和the client 在本地cache中具有相同的元数据 (需要获取3 heartbeats)， 否则service是不能被clients发现的。也可以使用`eureka.instance.leaseRenewalIntervalInSeconds`改变周期，这样就可以加速clients链接其他services的进程. 生产中保持缺省会更好，因为有一些服务内部的计算指令会设想租赁更新周期（make assumptions about the lease renewal period）.

1.11 Zones
If you have deployed Eureka clients to multiple zones than you may prefer that those clients leverage services within the same zone before trying services in another zone. 需要正确配置Eureka clients。
首先，需要确保把Eureka servers配置给每一个zone，并且互为对等点（peers）。 查看[zones and regions](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/1.4.4.RELEASE/multi/multi_spring-cloud-eureka-server.html#spring-cloud-eureka-server-zones-and-regions)这一章获取更详细的信息.

接下来需要通知Eureka你的service在哪个zone。可以使用`metadataMap` 所有权来实现. 例如，如果`service 1`被配置到`zone 1 `和`zone 2`你需要在`service 1`里按照如下所示来设置Eureka属性。
**Service 1 in Zone 1**

    eureka.instance.metadataMap.zone = zone1
    eureka.client.preferSameZoneEureka = true
**Service 1 in Zone 2**

    eureka.instance.metadataMap.zone = zone2
    eureka.client.preferSameZoneEureka = true