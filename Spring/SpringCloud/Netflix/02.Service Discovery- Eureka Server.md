# 2. Service Discovery: Eureka Server #

## 2.1 How to Include Eureka Server ##
要想在你的程序中涵盖Eureka Server需使用以下方法：grope语句  `org.springframework.cloud`开头，以及artifact id `spring-cloud-starter-netflix-eureka-server`. 查看 [Spring Cloud Project page](https://projects.spring.io/spring-cloud/) 获取更多信息，以使用当前的Spring Cloud Release Train设置你的编译系统（build system）。

## 2.2 How to Run a Eureka Server ##

例子：

    @SpringBootApplication
    @EnableEurekaServer
    public class Application {
    
    public static void main(String[] args) {
    new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
    
    }

server的home page具有 UI, 以及在`/eureka/*`下的 每个一般Eureka 功能的HTTP API 端点。
Eureka 背景阅读:  [flux capacitor](https://github.com/cfregly/fluxcapacitor/wiki/NetflixOSS-FAQ#eureka-service-discovery-load-balancer) 和 [google group discussion](https://groups.google.com/forum/?fromgroups#!topic/eureka_netflix/g3p2r7gHnN0)。

[Tip]
由于Gradle’s依赖性解决原则以及parent bom feature的缺失,简单依据spring-cloud-starter-netflix-eureka-server可能引起程序启动失败。 为弥补这种情况，必需添加Spring Boot Gradle plugin，并且 Spring cloud starter parent bom必须以下述方式导入:

**build.gradle. **
    
    buildscript {
      dependencies {
    classpath("org.springframework.boot:spring-boot-gradle-plugin:1.5.10.RELEASE")
      }
    }
    
    apply plugin: "spring-boot"
    
    dependencyManagement {
      imports {
    mavenBom "org.springframework.cloud:spring-cloud-dependencies:Edgware.SR2"
      }
    }
## 2.3 High Availability, Zones and Regions ##
Eureka server不具有后端储存（backend store），但是在注册中心的这种service instances都必须发送Heartbeats，用以使他们的注册数据保持最新（因此Eureka server可以在寄存器中处理）。Clients也具有eureka registrations的缓存（in-memory cache）（因此对于每个service的单次请求都不得不访问注册中心）。
默认每个Eureka server也是Eureka client，并且需要（至少一个）服务URL来定位peer。如果不提供URL，service也会运行工作，但是会倾倒（shower）出伴随大量噪声的logs ，而不能注册到peer。

查看[below for details of Ribbon support](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/1.4.4.RELEASE/multi/multi_spring-cloud-ribbon.html)  Zones and Regions.

## 2.4 Standalone Mode ##
两个缓存（client and server）的整合以及heartbeats会使 Eureka server失效，需要有部分监控或弹性的运行时间来维持（alive）（Cloud Foundry）。在独立模式下，倾向于关闭client side behaviour，因此不需要一直尝试或失效来到达peers。例如：
**application.yml (Standalone Eureka Server). **

    `server:
      port: 8761
    
    eureka:
      instance:
    hostname: localhost
      client:
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/`

  ` serviceUrl` 在local instance中指向同样的host

## 2.5 Peer Awareness ##
Eureka运行多重实例（multiple instances）及互相登记可以更有弹性及可用性。事实上，这是默认行为，因此需要给peer添加有效的`serviceUrl`，例如：

**application.yml (Two Peer Aware Eureka Servers)**

    ---
    spring:
      profiles: peer1
    eureka:
      instance:
    hostname: peer1
      client:
    serviceUrl:
      defaultZone: http://peer2/eureka/
    
    ---
    spring:
      profiles: peer2
    eureka:
      instance:
    hostname: peer2
      client:
    serviceUrl:
      defaultZone: http://peer1/eureka/
此例中含有一个YAML file， 运行在不同的Spring profiles中，可以在2个hosts (peer1 and peer2)中运行同样的server。可以使用这种构架来检测单个host中的peer awareness（不需要很多数据），通过操控`/etc/hosts`来解析（resolve）hoet names。事实上，如果程序在已知hostname的机器中运行，`eureka.instance.hostname`不是必须的（默认使用`java.net.InetAddress`来查询）。
只要单边能够互相联系，就可以给系统附加多重peers ，就可在彼此间同步注册信息。如果peers是物理上隔离（在一个数据中心或多个数据中心中），那么系统原则上可以在split-brain式失效（ split-brain type failures）中幸存。

## 2.6 Prefer IP Address ##
一些情况下，对Eureka来说，公告服务器的IP而非hostname更可取。设置`eureka.instance.preferIpAddress` 为` true `，当程序向eureka注册时，会使用IP而非hostname。


如果Java并不能决定hostname, IP会被发送给Eureka. 只能通过 `eureka.instance.hostname`来设置hostname。 在运行时使用环境变量来设置hostname，例如：`eureka.instance.hostname=${HOST_NAME}`。
