# 5. Hystrix Timeouts And Ribbon Clients #

当使用缠绕着Ribbon clients的Hystrix命令时，你希望确保Hystrix的超时设置比Ribbon更长，包括任何可能会执行的潜在复执（retries）。例如，如果Ribbon连接超时是1秒，Ribbon client可能会重复请求3次，那么Hystrix的超时设置应该比3秒稍长。

## 5.1 How to Include Hystrix Dashboard #

使用group语句`org.springframework.cloud`开头， artifact id 为`spring-cloud-starter-hystrix-netflix-dashboard`。
运行Hystrix Dashboard使用 `@EnableHystrixDashboard`注释Spring Boot main class。在Hystrix client 程序中，然后访问`/hystrix`，并将显示面板（dashboard）指向个体实例`/hystrix.stream`终端。

[Note]
当链接使用HTTPS的 `a /hystrix.stream` 终端时，服务器用过的证书一定要被JVM信任。如果证书不被信任，必须要将证书导入进JVM，从而使 Hystrix Dashboard能与 stream终端成功连接。

## 5.2 Turbine ##

就系统总体health来说，查看个体实例 Hystrix 数据不是很有用。 Turbine是一个应用程序，为了能在Hystrix Dashboard中使用将所有相关的`/hystrix.stream`终端凝聚（aggregates）进组合的` /turbine.stream` 。Individual instances 是由Eureka定位。运行Turbine与使用` @EnableTurbine `注释来注释一样简单 (例如使用 spring-cloud-starter-netflix-turbine来设置 classpath)。所有的文件配置属性来自于[the Turbine 1 wiki ](https://github.com/Netflix/Turbine/wiki/Configuration-(1.x))应用。唯一的不同是： 除非 `turbine.instanceInsertPort=false.`否则`turbine.instanceUrlSuffix `不需要预留端口。


一般，通过查找hostName和Eureka中port入口，Turbine在注册过的实例上寻找 `/hystrix.stream` 终端,然后附加`/hystrix.stream `给它。.如果实例的元数据包含`management.port`, 就会被用来给` /hystrix.stream `终端替换端口值。默认情况, 元数据入口 `management.port`等同于 `management.port`配置属性, 使用下述配置元数据入口可以被覆盖：

    eureka:
      instance:
    metadata-map:
      management.port: ${management.port:8081}

配置关键字`turbine.appConfig` 是eureka serviceIds列表，turbine可以用来查找instances. turbine stream 然后被用于Hystrix dashboard， Hystrix dashboard使用类似下面这样的url : *http://my.turbine.sever:8080/turbine.stream?cluster=CLUSTERNAME *(如果名字是"default"那么集群参数（the cluster parameter）可以省略). The cluster parameter必须匹配于  `turbine.aggregator.clusterConfig`的一个入口。eureka 的返回是大写（uppercase）, 因此如果有一个叫做"customers"的app注册到Eureka，我们希望它可以正常运行:
    
    turbine:
      aggregator:
    clusterConfig: CUSTOMERS
      appConfig: customers

若需要按客户要求定制，Turbine应当使用cluster names (不想将集群名称cluster names储存进`turbine.aggregator.clusterConfig` configuration)来提供`TurbineClustersProvider` 。

clusterName可以由`turbine.clusterNameExpression`中的 SPEL 表达式定制， root `InstanceInfo`的实例。缺省值是 `appName`, 意味着Eureka serviceId不再作为 cluster key (例如用户的`InstanceInfo` 具有一个`appName`是"CUSTOMERS")。 ` turbine.clusterNameExpression=aSGName`不同, 它是从 AWS ASG name中获取cluster name。例如：
    
    turbine:
      aggregator:
    clusterConfig: SYSTEM,USER
      appConfig: customers,stores,ui,admin
      clusterNameExpression: metadata['cluster']

上例中4个services的cluster name被从 metadata map中提取出来, 预计包含"SYSTEM" 和 "USER"值。

对所有的app使用"default" cluster需要一串文字表达式（使用单引号，如果在YAML 中要避开双引号）：
    
    turbine:
      appConfig: customers,stores
      clusterNameExpression: "'default'"

Spring Cloud提供一个`spring-cloud-starter-netflix-turbine` ，具有所有在运行Turbine server时所需要获取的dependencies。只需要创建一个Spring Boot应用程序并使用`@EnableTurbine`来注释。

[Note]
默认Spring Cloud允许Turbine使用host和 port来允许每个host、每个cluster的多线程（multiple processes）。如果希望建立在Turbine上本地Netflix 行为不允许允许每个host、每个cluster的多线程（multiple processes） (instance id的关键字是hostname), t那么就设置`turbine.combineHostPort=false`。

## 5.3 Turbine Stream ##

在某些环境下(例如 PaaS设置),从所有的分布式Hystrix commands中提取权值的典型Turbine模式是不工作的. 这种情况下你或许会想要把你的Hystrix commands权值传送给Turbine,Spring Cloud能够使用messaging来使其有效。所有你需要对client做的就是给 `spring-cloud-netflix-hystrix-stream` 附加 dependency 并且选择 `spring-cloud-starter-stream-*` （参考Spring Cloud Stream 文件, 如何配置 client credentials,但是应该为local broker解决  box？).

在服务器端创建Spring Boot application并使用`@EnableTurbineStream` 标记，默认会在8989端口出现 (将Hystrix dashboard指向该port, any path)。也可以使用`server.port` 或者 `turbine.stream.port`来定制端口。如果在类路径（classpath）上有`spring-boot-starter-web` 和 `spring-boot-starter-actuator`也可以实现相同功能, 就可以在另一个分开的、提供`management.port`的端口开发 Actuator endpoints(缺省使用Tomcat)。

也可以将Hystrix Dashboard指向Turbine Stream Server而非individual Hystrix streams。如果Turbine Stream运行在port 8989 on myhost, 就在Hystrix Dashboard的stream输入框中键入* http://myhost:8989*。Circuits会被置于serviceId之前, 然后是点, 接下来是circuit name。

Spring Cloud提供`spring-cloud-starter-netflix-turbine-stream` ，具有运行Turbine Stream server所需的所有dependencies- 只需要附加Stream binder。例如： `spring-cloud-starter-stream-rabbit`。因为是Netty-based，所以需要Java 8 来运行app。