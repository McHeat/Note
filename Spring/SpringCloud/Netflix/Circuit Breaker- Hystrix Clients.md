# 3. Circuit Breaker: Hystrix Clients #
Netflix创建了一个库调用：[Hystrix](https://github.com/Netflix/Hystrix)实现 [circuit breaker pattern](https://martinfowler.com/bliki/CircuitBreaker.html)。在微服务构架下具有多层服务响应。

**Figure 3.1. Microservice Graph**
![](https://raw.githubusercontent.com/spring-cloud/spring-cloud-netflix/1.4.x/docs/src/main/asciidoc/images/Hystrix.png)
下层服务的服务失败可能引起连锁故障直达用户。在`metrics.rollingStats.timeInMilliseconds` (default: 10 秒)创建的滚动窗口下，当特定服务的calls量比`circuitBreaker.requestVolumeThreshold`（默认20个请求）更大时，失效率也会比`circuitBreaker.errorThresholdPercentage `(default: >50%)更大，环路及呼叫（call）不能建立。为避免出错及开环，开发者可以提供回退（fallback）。

**Figure 3.2. Hystrix fallback prevents cascading failures**
![](https://raw.githubusercontent.com/spring-cloud/spring-cloud-netflix/1.4.x/docs/src/main/asciidoc/images/HystrixFallback.png)

使用开环阻止连锁故障，允许压制或使服务时间失效来进行恢复。回退（fallback）是另一种Hystrix protected call，静态数据或sane空值。fallbacks可以被链接，因此第一个fallback值制作其他的call，这些call反过来回退到静态数据。

## 3.1 How to Include Hystrix ##

使用group `org.springframework.cloud`开头，以及人工 id `spring-cloud-starter-netflix-hystrix`。 参见[Spring Cloud Project page](https://projects.spring.io/spring-cloud/)来使用当前Spring Cloud Release Train设置编译系统。

Example boot app:

    @SpringBootApplication
    @EnableCircuitBreaker
    public class Application {
    
    public static void main(String[] args) {
    new SpringApplicationBuilder(Application.class).web(true).run(args);
    }
    
    }
    
    @Component
    public class StoreIntegration {
    
    @HystrixCommand(fallbackMethod = "defaultStores")
    public Object getStores(Map<String, Object> parameters) {
    //do stuff that might fail
    }
    
    public Object defaultStores(Map<String, Object> parameters) {
    return /* something useful */;
    }
    }

`@HystrixCommand`是由Netflix的库调用"[javanica](https://github.com/Netflix/Hystrix/tree/master/hystrix-contrib/hystrix-javanica)"提供。Spring Cloud自动覆盖（wraps）Spring beans，Spring beans的标注存在于与Hystrix的断路器相连的代理服务器。
配置`@HystrixCommand` 可使用`commandProperties`，归属于`@HystrixProperty`注释列表，可参考[这里](https://github.com/Netflix/Hystrix/tree/master/hystrix-contrib/hystrix-javanica#configuration)。 [Hystrix wiki ](https://github.com/Netflix/Hystrix/wiki/Configuration)详细介绍了可用性能。
## 3.2 Propagating the Security Context or using Spring Scopes ##
因为缺省说明？（it）在线程池里执行命令（以防超时），如果想要多线程局部环境传输给`@HystrixCommand`，可使缺省说明不运作。通过要求Hystrix使用不同的"Isolation Strategy"可以切换Hystrix 使用相同的thread，在caller 使用同样的配置时，或直接在注释表里（caller ）？。
    
    @HystrixCommand(fallbackMethod = "stubMyService",
    commandProperties = {
      @HystrixProperty(name="execution.isolation.strategy", value="SEMAPHORE")
    }
    )
...
 如果使用`@SessionScope` 或 `@RequestScope`也同样适用。当因为运行异常而这样做时会显示不能发现作用域环境。
也可以选择设置`hystrix.shareSecurityContext`性质为`true`。这样做会自动配置Hystrix并发策略插件钩？ （concurrency strategy plugin hook），该Hystrix concurrency strategy plugin hook通过Hystrix command将`SecurityContext`从主线上传送到使用的thread上。Hystrix不允许多程hystrix concurrency strategy被注册，因此需将自己的`HystrixConcurrencyStrategy`作为Spring bean清空来使扩展机制（extension mechanism）可用。Spring Cloud会在Spring context中搜寻执行情况，并将其包裹进（wrap）自己的插件里（plugin）。

## 3.3 Health Indicator ##健康指标
链接的circuit breakers的状态也会显露给呼叫程序的（calling application）`/health`终端。
    
    {
    "hystrix": {
    "openCircuitBreakers": [
    "StoreIntegration::getStoresByLocationLink"
    ],
    "status": "CIRCUIT_OPEN"
    },
    "status": "UP"
    }

## 3.4 Hystrix Metrics Stream ##

使Hystrix metrics stream有效包括`spring-boot-starter-actuator`的依赖性。这会使`/hystrix.stream`作为管理终端显示。

     <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
