# SpringCloudStream
 Spring Cloud Stream是用于构建基于消息驱动微服务应用的框架。基于Spring Boot技术，Spring Cloud Stream可创建独立的、产品级的Spring应用，使用Spring Integration来连接消息代理。  
 `@EnableBinding`：快速连接到MessageBroker，使用接口作为参数。接口内声明input|output通道  
 `@StreamListener`：接收流处理的事件  
 `@Input`：声明input通道，用于接收消息到应用中  
 `@Output`：声明output通道，用于发送消息到应用外  
## SpringCloudStream特性
	|--	SpringCloudStream应用模型
	|	|--	原理：
	|	|	1.应用使用SpringCloudStream注入的input|output通道与外界交流
	|	|	2.channel通过中间件特定绑定实现与外部代理连接
	|--	Binder抽象类
	|	|--	提供了支持Kafka和RabbitMQ的Binder实现
	|	|--	提供了TestSupportBinder，用于测试时直接连接channel并判断收到的消息
	|	|--	可通过可扩展API写自己的Binder
	|	|--	通过SpringBoot配置连接中间件，自动检测并使用在classpath下的Binder
	|	|	spring.cloud.stream.bindings.input.destination设置为raw-sensor-data
	|--	持久化publish-subscribe支持
	|	|--	降低了发布者和消费者的复杂化，便于拓扑添加新应用
	|--	消费者组支持
	|	|--	同一个应用的不同实例属于消费者竞争关系。
	|	|--	通过spring.cloud.stream.bindings.<channelName>.group属性设置组
	|	|--	持久性：一旦group的订阅关系被创建，即使其中的所有应用都停止也会接收消息
	|--	Partitioning support
	|	|--	分区处理保证了消息被同一个消费者使用
	|--	A pluggable Binder API
使用SpringCloudStream
	|--	通过在应用的configuration类上添加@EnableBinding注解绑定MessageBroker
	|--	@EnableBinding注解可使用多个Bound接口类（内部使用@Input|@Output注解创建channel）作为参数，接口中包含代表绑定组件的方法
	|--	@Input&@Output
	|	|--	在一个接口中可定义任意数量的input|output通道
	|	|-- 可通过@Input&@Output为channel定义通道名称
	|	|--	@Source用于指定单一的出站通道，内部使用了@Output注解方法
	|	|--	@Sink用于指定单一的入站通道，内部使用了@Input注解方法
	|	|--	@Processor用于有入站和出站通道的应用，继承了Sink和Source接口
	|--	使用Bound Channel
	|	|--	1.注入Bound接口，通过接口获取channel来发送或接收消息，如注入Source接口
	|	|--	2.直接注入MessageChannel，通过channel名称来自动装载，如注入Source接口中的output渠道，可通过指定名称注入
	|--	发布和消费消息
	|	|--	可通过SpringIntegration注解（SpringCloudStream基于此，不作分析）
	|	|--	通过SpringCloudStream的@StreamListener注解
	|	|		@StreamListener的扩展类有：@MessageMapping，@JmsListener，@RabbitListener.....
	|	|		这些扩展类添加了内容类型管理及强制类型等特点
	|	|--	提供了MessageConverter机制来处理数据类型转化并分发到@StreamListener注解方法
	|	|		方法的参数可使用@Payload、@Headers和@Header
	|	|		@SendTo(...)来指定返回结果发送channel
	|--	spring-cloud-stream-reactive
	|	|--	输入数据和输出数据通过连续的数据流处理
	|	|--	使用@StreamListener来设置reactive处理器
	|	|		1.@StreamListener不能指定input|output，而是通过方法参数和返回值确定
	|	|		2.方法的参数必须指定@Input&@Output来说明数据的来源和目标
	|	|		3.如果有返回值，将会被注解为@Output，指明数据送往哪里
	|--	Reactor处理器
	|	|--	@Input注解的参数，支持Reactor的Flux类型。
	|	|		其中的T可以使用Message或根据Message的Content-Type转换后的POJO
	|	|--	@Output注解的参数，支持Reactor的FluxSender类型。
	|	|		FluxSender会绑定到方法创建的Flux输出
	|	|		仅当方法有多个输出时才推荐使用参数作为输出
	|	|--	Reactor处理器支持Flux返回类型，必须添加@Output注解
	|--	RxJava 1.x处理器
	|	|--	类似Reactor处理器，但是使用Observable和ObservableSender参数和返回类型
	|--	Aggregation（聚合）
	|	|--	对于版本1.0的SpringCloudSteam，聚合仅支持：
	|	|		1.sources：有唯一一个名称为output的输出channel的application
	|	|		2.sinks：有唯一一个名称为input的输入channel的application
	|	|		3.processors：有唯一一个名称为input的输入channel和名为output的输出channel的application
	|	|--	通过一系列相互连接的应用聚合在一起，某一个元素的输出channel连接到下一个元素的输入channel
	|	|		1.通过source或processor开始
	|	|		2.包括任意个数量的processor
	|	|		3.必须以processor或sink结束
	|	|--	使用AggregateApplicationBuilder工具类来实现聚合
	|	|	当Configuartion类标识了SpringBootApplication时，聚合应用中的每一个组件（source|sink|processor）必须在不同的package中
	|	|		from()方法添加开始组件，namespace()指定参数前缀、args()
	|	|		to()方法添加结束组件
	|	|		via()添加中间processor
Binder
	|--	Producer：向channel发送消息的组件称为Producer
	|	|--	bindProducer()：
	|	|	第一个参数是broker中的目标的名称
	|	|	第二个参数是发送消息的本地channel
	|	|	第三个参数是channel创建的适配器的properties
	|--	Consumer：从channel中获取消息的组件称为Consumer
	|	|--	bindConsumer()
	|	|	第一个参数是broker中的目标的名称
	|	|	第二个参数是本地consumer组的名字，每个组都会收到producer发送的消息的备份。同组的consumer仅有一个可收到此备份
	|	|	第三个参数是接收消息的本地channel
	|	|	第四个参数是channel创建的适配器的properties
	|--	BinderSPI
	|	|--	核心接口Binder：用于连接input|output到外部中间件
	|	|		Binder<T, C extends ConsumerProperties, P extends ProducerProperties>
	|	|		输入输出绑定对象：目前只支持MessageChannel
	|	|		可扩展的消费者和生产者属性：允许特定的Binder实现添加足够的属性
	|	|--	典型binder实现类组成如下：
	|	|		1.实现Binder接口的类
	|	|		2.Spring的@Configuration用于创建连接中间件的bean
	|	|		3.classpath下META-INF/spring.binders文件，包含了一个或多个binder定义
	|--	BinderDetection
	|	|--	通过SpringBoot的auto-configuration来配置绑定程序。
	|	|		<dependency>
	|	|			<groupId>org.springframework.cloud</groupId>
	|	|			<artifactId>spring-cloud-stream-binder-rabbit</artifactId>
	|	|		</dependency>
	|	|--	多个Binder
	|	|	当classpath下有多个binder时，应用必须指明每个channel绑定到哪个binder。
	|	|	每个binder配置都包含META-INF/spring.binders文件：
	|	|		key值是binder的标识名称
	|	|		value值是configuration类列表，每个都包含了有且仅一个Binder的bean定义
	|	|--	全局定义：使用spring.cloud.stream.defaultBinder属性
	|	|--	单独定义：为每个channel绑定binder
	|	|		spring.cloud.stream.bindings.input.binder=kafka
	|	|		spring.cloud.stream.bindings.output.binder=rabbit
	|	|--	连接到多系统
	|	|		应用需要连接到多个相同类型的代理时，可指定多个带有不同environment设置的binder配置。
	|	|		当明确指定binder配置时，默认的binder配置会全部失效，需在配置中包含所有的binder。
	|	|		spring:
	|	|		  cloud:
	|	|		    stream:
	|	|		  	  bindings:
	|	|		  	    input:
	|	|		  	      destination: foo
	|	|		          binder: rabbit1
	|	|		  	    output:
	|	|		  	      destination: bar
	|	|		  	      binder: rabbit2
	|	|		  	  binders:
	|	|		  	    rabbit1:
	|	|		  	      type: rabbit			# binder的类型，通常是META-INF/spring.binders文件中的key值
	|	|				  #inheritEnvironment: true	# 配置是否继承应用的environment，默认true
	|	|		  	      environment:			# 自定义binder的environment属性的根路径。binder所在context不是应用context的子类。默认empty
	|	|		  	        spring:
	|	|		  	          rabbitmq:
	|	|		  	            host: <host1>
	|	|				   defaultCandidate: true	# binder配置是否参与默认binder，或仅显式使用。可阻止binder配置影响默认处理过程
	|	|		        rabbit2:
	|	|		  	      type: rabbit
	|	|		  	      environment:
	|	|		  	        spring:
	|	|		  	          rabbitmq:
	|	|		  	            host: <host2>
	
配置选项
	|--	SpringCloudStream支持全局配置选项，也支持bindings和binder配置。binder允许添加额外的binding属性来支持特定中间件特性
	|--	SpringCloudStream属性
	|	  spring.cloud.stream.instanceCount
	|		应用部署实例个数。在使用Kafka和分区时必须设置。默认值：1
	|	  spring.cloud.stream.instanceIndex
	|		应用的实例索引；从0到instanceCount-1。CloudFoundry自动设置来匹配应用实例索引
	|	  spring.cloud.stream.dynamicDestinations
	|		动态绑定的destination列表。设置后仅列举的destination可绑定。默认值：empty
	|	  spring.cloud.stream.defaultBinder
	|		当配置多个binder时，默认使用的binder。默认值：empty
	|	  spring.cloud.stream.overrideCloudConnectors
	|		仅cloud profile激活且应用提供了Spring Cloud Connectors时适用。默认值：false
	|--	Binding属性
	|	|--	属性形式：spring.cloud.stream.bindings.<channelName>.<property>=<value>
	|	|		<channelName>代表了配置的channel的名称
	|	|		支持为全部channel设置属性值，形式：spring.cloud.stream.default.<property>=<value>
	|	|--	Channel属性
	|	|	  destination
	|	|		channel在绑定到的中间件的目标。
	|	|		如果channel绑定为消费者，可绑定到多个destination，名称之间使用逗号分隔。
	|	|		未设置时，将使用channel的名称为替代。默认值不可覆盖
	|	|	  group
	|	|		channel的消费者组。仅适用于输入绑定。默认值：null（匿名消费者）
	|	|	  contentType
	|	|		channel的content类型。默认值：null（不强制类型）
	|	|	  binder
	|	|		用于绑定的binder。默认值：null（使用默认binder）
	|	|--	Consumer属性（适用于输入绑定）
	|	|	  属性前缀：spring.cloud.stream.bindings.<channelName>.consumer.
	|	|		默认值设置：spring.cloud.stream.default.consumer
	|	|	  concurrency
	|	|		输入消费者的并发数。默认值：1
	|	|	  partitioned
	|	|		消费者是否从分区生产者获取数据。默认值：false
	|	|	  headerMode
	|	|		设置为raw时，不再执行header分析。默认值：embeddedHeaders
	|	|	  maxAttempts
	|	|		处理失败时，处理消息的尝试次数（包括第一次）。设置为1时将不再重试。默认值：3
	|	|	  backOffInitailInterval	默认值：1000
	|	|	  backOffMaxInterval		默认值：10000
	|	|	  backOffMultiplier			默认值：2.0
	|	|	  instanceIndex
	|	|		设置为大于等于0时，允许自定义消费者的实例索引。
	|	|		设置为负值时，消费者的实例索引默认为spring.cloud.stream.instanceIndex的值。默认值：-1
	|	|	  instanceCount
	|	|		设置为大于等于0时，允许自定义消费者的实例个数。
	|	|		设置为负值时，消费者的实例索引默认为spring.cloud.stream.instanceCount的值。默认值：-1
	|	|--	Producer属性（适用于输出绑定）
	|	|	  属性前缀：spring.cloud.stream.bindings.<channelName>.producer
	|	|	 	默认值前缀：spring.cloud.stream.default.producer
	|	|	  partitionCount
	|	|		使用分区时数据的目标分区的数量。
	|	|		默认值：1
	|	|	  partitionKeyExpression
	|	|		决定如何分区输出数据的SpEL表达式。设置后，channel的输出数据将分区，partitionCount必须设置大于1。默认值：null
	|	|	  partitionKeyExtractorClass
	|	|		PartitionKeyExtractorStrategy实现类。设置后，channel的输出数据将分区，partitionCount必须设置大于1。默认值：null
	|	|	  partitionSelectorClass
	|	|	  partitionSelectorExpression
	|	|		PartitionSelectorStrategy的实现类及自定义分区选择的SpEL表达式。两者互斥。
	|	|		当两者都没有设置时，通过hashCode(key) % partitionCount选择分区，key是通过partitionKeyExpression或partitionKeyExtractorClass计算得到。
	|	|		默认值：null
	|	|	  requiredGroups
	|	|		发布者必须确保发送到的组列表，通过逗号分隔。即使组是后来注册的。
	|	|	  headerMode
	|	|		设置为raw时，输出流不做header内置。默认值：embeddedHeaders
	|	|	  useNativeEncoding
	|	|		设置为true时，输出消息会被客户端直接序列化。默认值：false
	|--	使用动态绑定目标
	|	|--	通过BinderAwareChannelResolver的bean，可被@EnableBinding注解自动注册
	|	|--	spring.cloud.stream.dynamicDestinations属性可限制动态目标为预知的目标。未设置时，任何目标可被动态绑定。
	|	|		resolver.resolveDestination(target).send(MessageBuilder.createMessage(body,
	|	|					new MessageHeaders(Collections.singletonMap(MessageHeaders.CONTENT_TYPE, contentType)));
	|	|--	BinderAwareChannelResolver是公用的SpringIntegration对象DestinationResolver，可注入到其他组件中。
ContentType和转换
	|--	SpringCloudStream在输出信息中默认添加了contentType报文头
	|		对于不直接支持header的中间件，SpringCloudStream提供了自动包装输出信息的设计。
	|		对于支持header的中间件，SpringCloudStream可收到非SpringCloudStream应用的给定contentType
	|--	SpringCloudStream处理信息的两种方式：
	|		通过输入或输出信息的contentType设置
	|		通过@StreamListener注解的方法的参数映射
	|--	除了通过bindings的<channelName>.contentType属性来配置类型转换，还可通过应用的转换器来轻松的完成。
	|	  SpringCloudStream目前原生支持的类型转换：
	|		JSON <---> POJO
	|		JSON <---> Tuple
	|		Object <---> byte[]
	|		String <---> byte[]
	|		Object <---> plain text(调用object的toString方法)
	|--	MIME类型
	|	  MIME类型在指导如何转成String或byte[]内容时尤其有效。
	|		SpringCloudStream使用application/x-java-object;type=<XXX>来标识Java类型
	|--	SpringCloudStream的输入输出通道都支持转换。
	|	  极力推荐对输出消息进行转换。
	|	  对于输入消息的转换来说，尤其是转换为POJO时，@StreamListener会自动执行转换
	|--	自定义消息转换
	|	|--	SpringCloudStream除了内置的转换外，还支持注册自定义的消息转换实现。
	|	|	  org.springframework.messaging.converter.MessageConverter接口的bean会注册为自定义消息转换器。
	|	|	  如果想处理特定的content-type和目标类，可扩展AbstractMessageConverter抽象类，这对@StreamListener就足够了。
	|--	基于模式的(schema-based)消息转换器
	|	|--	通过spring-cloud-stream-schema模块可支持基于模式的消息转换器。当前支持性比较好的是ApacheAvro
	|	|--	ApacheAvro消息转换器
	|	|	|--	支持的消息转换器：
	|	|	|	  使用序列/反序列化对象的类信息的转换器
	|	|	|	  模式注册的转换器
	|	|	|--	AvroSchemaMessageConverter可通过预定义模式或类的可用模式信息来序列或反序列消息
	|	|	|	  使用方式：注册到上下文，可指定MIME。默认值为application/avro
	|	|--	模式注册支持
	|	|	|--	为了支持跨平台跨语言的便利性，序列化模型会依赖描述数据如何序列化为二进制的模式(schema)。
	|	|	|	  为了序列和解析数据，发送和接收方都需要可以使用描述二进制格式的schema。
	|	|	|	  模式注册允许使用文本形式(通常是JSON)存储schema信息，并供多个应用使用。
	|	|	|--	schema组成：
	|	|	|	  schema的逻辑名称subject、schema版本、schema描述数据的二进制形式的format
	|	|	|--	模式注册服务器
	|	|	|	  使用方式：
	|	|	|		添加spring-cloud-stream-schema-server到项目
	|	|	|		使用@EnableSchemaRegistryServer注解
	|	|	|		使用spring.cloud.stream.schema.server.path设置schema服务器的根路径
	|	|	|		配置spring.cloud.stream.schema.server.allowSchemaDeletion可删除schema，默认不可删除
	|	|	|	  API
	|	|	|		POST /
	|	|	|			注册新的schema。
	|	|	|		GET /{subject}/{format}/{version}
	|	|	|		GET /schemas/{id}
	|	|	|			返回已存在的schema。
	|	|	|		DELETE /{subject}/{format}/{version}
	|	|	|		DELETE /schemas/{id}
	|	|	|		DELETE /{subject}
	|	|	|			删除已存在的schema。
	|	|	|--	1.1.0.RELEASE版本的数据库表名是schema。从1.1.1.RELEASE版本开始改为SCHEMA_REPOSITORY。
	|	|--	模式注册客户端
	|	|	|--	SchemaRegistryClient接口是与模式注册服务器交互的客户端抽象类。
	|	|	|--	通过@EnableSchemaRegistryClient开启模式注册客户端
	|	|	|	疑问：通过共用同一数据库中的SCHEMA_REPOSITORY实现schema的共享？客户端如何连接到服务器？
	|	|	|		spring.cloud.stream.schemaRegistryClient.endpoint设置服务器地址及path
	|	|--	Avro模式注册客户端消息转换器
	|	|	|--	当开启了SchemaRegistryClient后，会自动配置ApacheAvr消息转换器
	|	|	|--	发送消息时，MessageConverter在渠道的contentType设置为application/*+avro时会被激活
	|	|	|		发出的消息会设置contentType报文头为application/[prefix].[subject].v[version]+avro
	|	|	|--	接收消息时，转换器根据消息的报文头推断并获取schema。反序列过程中将使用该schema。
	|--	@StreamListener和消息转换
	|	|--	@StreamListener注解不需要通过指定contenType就可转换输入消息。

跨应用交流
	|--	通过连接相邻的应用的输入输出目标实现多应用的互通
	|		spring.cloud.stream.bindings.<outChannelName>.destination=ticktock
	|		spring.cloud.stream.bindings.<inChannelName>.destination=ticktock
	|--	SpringCloudStream应用中的每个实例都会接收到关于实例个数和实例索引的信息
	|		spring.cloud.stream.instanceCount和spring.cloud.stream.instanceIndex
	|		通过SpringCloudDataFlow部署时，上述俩属性会自动配置;当SpringCloudStream单独启动时，属性必须正确设置
	|	  作用：
	|		1.对于解决分区行为很重要
	|		2.在Kafka绑定器中，为了正确的在多个消费者实例中分派数据，属性是必须的
	|--	分区
	|	|--	实现输出绑定发送分区数据
	|	|	1.设置且仅可设置partitionKeyExpression或partitionKeyExtractorClass属性中的一个，
	|	|	2.设置partitionCount属性
	|	|--	发送的消息通过公式key.hashCode % partitionCount计算出发送的目标（与instanceIndex相同）
	|	|--	PartitionKeyExtractorClass实现类可注册为bean来使用
	|	|--	配置分区输入绑定
	|	|		spring.cloud.stream.bindings.input.consumer.partitioned=true
	|	|		spring.cloud.stream.instanceIndex=3
	|	|		spring.cloud.stream.instanceCount=5

测试
	|--	Stream提供了@TestSupportBinder注解支持不需要连接消息系统来测试微服务应用。
	|		针对输出消息channel，@TestSupportBinder会注册一个订阅者，并把发出的消息保存在MessageCollector中。

健康检测
	|--	SpringCloudStream为binder提供了健康检测器。
	|		注册在binders的名下，通过设置management.health.binders.enabled属性开启或禁用

绑定器实现：
Apache Kafka Binder
	|--	jar包引用：org.springframework.cloud:spring-cloud-starter-stream-kafka
	|--	Kafka的绑定器实现将目标映射到Apache Kafka的Topic上。
	|		消费者组直接映射到同一个Apache Kafka上。
	|		分区也同样直接映射到Apache Kafka分区上。
	|--	配置选项：
	|		spring.cloud.stream.kafka.binder.brokers
	|			kafka绑定器连接的代理列表。默认：localhost
	|		spring.cloud.stream.kafka.binder.defaultBrokerPort
	|			设置brokers中未指定端口信息的代理的默认端口。默认值：9092
	|		spring.cloud.stream.kafka.binder.zkNodes
	|			指定Kafka绑定器连接的ZooKeeper节点列表。默认：localhost
	|		spring.cloud.stream.kafka.binder.defaultZkPort
	|			设置zkNodes中未设置port信息的默认呢port值。默认值：2181
	|		spring.cloud.stream.kafka.binder.configuration
	|			适用于binder创建的所有client的客户端KV映射值。此属性设置的值用于producer和consumer。默认：空
	|		。。。。。。

RabbitMQ Binder
	|--	jar包引用：org.springframework.cloud:spring-cloud-starter-stream-rabbit
	|--	RabbitMQ绑定器实现将每个目标映射到了TopicExchange上。
	|		对于每组消费者来说，Queue会绑定到这个TopicExchange上。
	|		每个消费者实例会在对应的组Queue上有一个Consumer。
	|		对于分区的生产者和消费者，队列会使用分区索引作为前缀，并使用分区索引作为路由key。

























	