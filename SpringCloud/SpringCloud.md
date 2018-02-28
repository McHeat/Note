# Spring Cloud

## 一、特性
Spring Cloud主要用于对典型的用户场景和可扩展机制提供良好的开箱即用的体验。
 + 分布式/版本控制的配置方式(Distributed/versioned configuration)
 + 服务注册和发现(Service Registration and discovery)
 + 路由(Routing)
 + 服务对服务的调动(Service-to-service calls)
 + 负载均衡(Load Balancing)
 + 断路器(Circuit Breaker)
 + 分布式通信(Distributed Messaging)

## 二、云原生应用(Cloud Native Applications)
 云原生是一种应用开发方式，提倡采用持续交付(Continuous Delivery，CD)和价值驱动(Value-driven)开发领域的最优体验。一个相关原则是12要素应用(12-factor App)。在12要素应用中，开发实践主要分配在交付和操作目的，比如使用声明式编程、管理和监控等。
 Spring Cloud在许多领域使用这种开发方式，首先从在分布式系统中所有组件需要或容易用到的一系列特性。在使用SpringCloud创建的SpringBoot应用中，这些特性的大多数都已覆盖到。其他特性包括在Spring Cloud发布的两个library中：Spring Cloud Context和Spring Cloud Commons。
- Spring Cloud Context  
 为应用的ApplicationContext提供功能和定制服务，包括引导context、加密、刷新域和环境端点。
- Spring Cloud Commons  
 提供了一套抽象类和不同Spring Cloud实现使用的公共类(如Spring Cloud Netflix和Spring Cloud Consul)。

如果获取到Illegal key size原因的异常，并且使用的sunJdk时，需要安装Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy文件(JDK/jre/lib/security路径)。

