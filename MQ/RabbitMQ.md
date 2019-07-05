# RabbitMQ

## AMQ协议
### 一、AMQP作为一种RPC传输机制  
+ 与大多数RPC不同的是，AMQP规范中允许服务器和客户端都可以发出命令。  
+ 同时，AMQP规范定义了与RabbitMQ进行通信的信道。一个AMQP连接可以有多个信道，允许客户端和服务器之间进行多次会话。(多路复用)  

### 二、AMQP RPC帧结构  
1. AMQP帧由五个不同的组件组成：  
  + 帧类型  
  + 信道编号  
  + 以字节为单位的帧有效载荷大小  
  + 帧有效载荷  
  + 结束字节标识(ASCII值206-0xce)   
2. 帧类型：
  + **协议头帧**：连接RabbitMQ，仅使用一次  
  + **方法帧**：发送或接收RabbitMQ的RPC请求或响应   
  + **内容头帧**：消息的大小和属性
  + **消息体帧**：消息的内容
  + **心跳帧**：客户端与RabbitMQ之间的校验机制，确保连接可用且正常工作  
3. 帧的发送顺序：方法帧、内容头帧以及一个或多个消息体帧   

### 三、使用协议  
**交换器**和**队列**是AMQ模型中的一等公民。  
1. 声明交换器  
  使用**Exchange.Declare**命令可创建交换器，提供了定义交换器名称和类型的参数，以及用于消息处理的其他元数据。  
  RabbitMQ在创建了交换器之后将发送一个**Exchange.DeclareOk**方法帧作为响应。创建失败则使用Channel.Close命令关闭发送Exchange.Declare命令的信道，响应将包含一个数字回复编码和文本值，用以说明失败并关闭信道的原因。  
2. 声明队列  
  交换器创建成功后，发送**Queue.Declare**命令创建一个队列，成功时返回**Queue.DeclareOk**，如果执行失败同样会关闭信道。  
  在声明一个队列时，多次发送同一个Queue.Declare命令不会有任何副作用。RabbitMQ不会处理后续的队列声明，只会返回队列有关的有用信息。  
3. 绑定队列到交换器  
  **Queue.Bind**命令可指定一个队列绑定到指定的交换器，成功会收到**Queue.BindOk**方法帧。  
4. 发布消息到RabbitMQ  
  消息到达RabbitMQ之前，客户端程勋发送了一个**Basic.Publish**方法帧、一个内容头帧和至少一个消息体帧。  
  RabbitMQ检查Basic.Publish方法帧获取消息的交换器名称和路由键并与配置交换器的数据库进行匹配。  
  交换器匹配成功后，判断该交换器中的绑定信息，并通过路由键寻找匹配的队列。队列匹配成功后，以FIFO的顺序将消息放入队列中（消息的引用）。  
  **Basic.Properties**中的*delivery-mode*属性决定了消息保存在内存中还是写入到磁盘中。  
5. 从RabbitMQ中消费消息  
  + 消费者应用程序通过**Basic.Consume**命令订阅RabbitMQ中的队列。其中no_ack参数为true时，RabbitMQ连续发送消息直到接收到Basic.Cancel命令或消费者断开连接；no_ack参数为false时，消费者必须通过发送**Basic.Ack** RPC请求确认收到的消息。  
  + 服务器使用**Basic.ConsumeOk**进行响应，通知客户端将释放消息。  
  + 消费者通过**Basice.Deliver**方法帧、内容头帧和消息体帧接收消息。  
  + 消费者可通过发送**Basic.Cancel**命令停止接收消息（异步发出，在接收到**Basic.CancelOk**之前仍然接收消息）。  
  
## 消息属性
### 一、Basic.Properties  
包含在内容头帧中的消息属性是一组预定义的值，通过Basic.Properties数据结构进行指定。  

| 属性 | 类型 | 用途 | 使用建议或特殊用法 |
| -- | -- | -- | -- | 
| content-type | short-string | 应用程序 | 使用mime-types指定消息体的类型 |
| content-encoding | short-string | 应用程序 | 指定消息体是否以某种特殊方式编码，如zlib、deflat或Base64 |  
| message-id | short-string | 应用程序 | 唯一的标识符，例如在应用程序中使用UUID来标识消息 |  
| correlation-id | short-string | 应用程序 | 通过携带关联消息的message-id作为另一个消息的响应；或传送关联消息的事务ID或其他类似数据。 |  
| timestamp | timestamp | 应用程序  | 用文本字符串表示的纪元时间或UNIX时间戳值，表示消息的创建时间，可用于消费者评估消息投递过程的性能。 | 
| expiration | short-string | RabbitMQ | 文本字符串表示的纪元时间或UNIX时间戳值，表示消息的过期时间，如果已过期的消息发布到服务器，则该消息不会被路由到任何队列，而是直接被丢弃。 |  
| delivery-mode | octet | RabbitMQ | 消息持久化标识：1表示非持久化消息，有较低的消息投递延迟性；2表示持久化消息，可保证消息的可靠投递。 |  
| app-id | short-string | 应用程序 | 定义发布消息的应用程序 | 
| user-id | short-string | 两者兼有 | 一个自由格式的字符串，如果启用该属性，RabbitMQ将验证当前连接的用户，如果不匹配则丢弃消息。 |  
| type | short-string | 应用程序 | 一个文本字符串，用来在应用程序中描述消息或有效负载的类型 |
| headers | table | 两者兼有 | 一个自由格式的键/值表，可用来添加消息相关的附加元数据；RabbitMQ可以根据headers表中填充的值路由消息，而不需要依赖于路由键。 |
| priority | octet | RabbitMQ | 队列中表示优先顺序的属性，定义为一个介于0到9之间的整数（RabbitMQ中0-255） |
| cluster-id/reserved | 没有任何实现的行为。规避使用。 |
| reply-to | 未明 | 未明 | 构建一个用来回复消息的私有响应队列？ |

## 消息发布的性能权衡
### 一、 投递速度和可靠投递的抉择
消息的投递速度根据可靠性的选择**由快到慢**：  
+ 没有保障
+ 失败通知
+ 发布者确认
+ 备用交换器
+ 高可用队列
+ 事务
+ 基于事务的高可用队列
+ 消息持久化  

在RabbitMQ中，旨在创建可靠投递的每个机制都会对性能产生一定的影响。应根据相应的场景选择合适的解决方案，以平衡高性能和消息传递的安全性。  

1. **没有保障的消息投递**  
在完美的世界中，无须任何额外的配置或步骤，RabbitMQ就能可靠地投递消息。  
在非核心应用程序中，正常的消息发布不必处理每个可能的故障点。在没有额外可靠发布机制的情况下传递监控数据，配置项可以更少，处理开销也更低，并且比可靠消息投递更简单。  
2. **mandatory设置**  
mandatory标志是一个与**Basic.Publish** RPC命令一起传递的参数，告诉RabbitMQ如果消息不可路由，应该通过**Basic.Return** RPC命令将消息返回给发布者。（该模式只通知失败）  
Basic.Return调用时一个RabbitMQ的异步调用，并且在消息发布后的任何时候都可能发生，应为这个调用设置监听器以确保调用不会被忽略。  
3. **发布者确认**  
  + 发布消息前，消息发布者向RabbitMQ发出**Confirm.Select** RPC请求，并等待**Confirm.SelectOk**响应以获知投递确认已经被启动。  
  + 针对消息发布者发送给RabbitMQ的每条消息，服务器会发送一个确认响应(**Basic.Ack**)或否定确认响应(**Basic.Nack**)，其中包含一个整数用于指定确认消息的偏移值。  
  + 发布者确认无法与事务一起工作，是AMQP TX流程的一种轻量级并提供更高性能的替代方案。  
4. **备用交换器**  
备用交换器是RabbitMQ对AMQ模型的扩展，在第一次声明交换器时被指定，在交换器无法路由消息时，消息会被路由到这个备用交换器。  
在设置接收消息的主交换器时，将`alternate-exchange`参数添加到Exchange.Declare命令中。
  
  
  
  
  
  
  
  
  
  
  
  
  