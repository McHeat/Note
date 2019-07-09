## Redis(REmote DIctionary Server)
 开源的可基于内存亦可持久化的日志型、Key-Value型数据库，称为数据结构服务器
 
### 一、启动

 Windows	
 ```
 redis-server.exe redis.windows.conf 	# 服务器
 redis-cli.exe -h 127.0.0.1 -p 6379		# 客户端
 ```  

 Linux
```
 ./redis-server redis.conf				# 服务器
 ./redis-cli							# 客户端 
```  

## Redis入门

### 二、配置
 1. 配置文件位于Redis安装目录下，文件名为redis.conf  
 2. CONFIG命令可查看或设置配置项  
   获取配置：CONFIG GET CONFIG_SETTING_NAME  
   编辑配置：CONFIG SET CONFIG_SETTING_NAME NEW_CONFIG_VALUE  
 3. 配置参数请参照api
 
### 三、数据类型
 String(字符串)、Hash(哈希)、List(列表)、Set(集合)、Zset(有序集合)

### 四、命令
 redis-cli 连接本地redis服务
 redis-cli -h host -p port -a password	连接远程redis服务
### 五、 键(key)
 `DEL key`		    删除存在的key  
 `DUMP key`	        序列化给定key并返回  
 `EXISTS key`		检查是否存在  
 `EXPIRE key seconds`		设置过期时间  
 `EXPIREAT key timestamp`		设置过期时间戳  
 `PEXPIRE key milliseconds`		设置过期时间（毫秒）  
 `PEXPIREAT key milliseconds-timestamp`		设置过期时间戳（毫秒）  		
 `KEYS pattern`	查找符合给定模式的key  
 `MOVE key db`		移动key到指定数据库  
 `PERSIST key`		移除过期时间  
 `TTL|PTTL key`	秒|毫秒方式返回key剩余过期时间  
 `RANDOMKEY`		随机返回key  
 `RENAME key newkey`		修改key名称  
 `RENAMENX key newkey`		修改key名称（newkey不存在时）  
 `TYPE key`		返回key存储的值的类型  
### 六、字符串（String）
 `SET key value`		设置key的值  
 `GET key`		获取key的值  
 `SETRANGE key offset value`		从偏移量offset开始覆写key的字符串值  
 `GETRANGE key start end`		返回key中字符串值的子字符  
 `GETSET key value`		将给定key值设为value，并返回旧值  
 `GETBIT key offset`		获取指定偏移量上的位  
 `SETBIT key offset value`		设置或清除指定偏移量上的位  
 `MSET key value [key value]`		同时设置一个或多个key-value对  
 `MGET key1 [key2...]`		获取所有给定key的值  
 `SETNX key value`		仅key不存在时设置key值  
 `MSETNX key value [key value]`		同时设置一个或多个key-value对（仅当所有给定key不存在时）  
 `SETEX key seconds value`		设置key的value并指定过期时间  
 `PSETEX key milliseconds value`	设置key的value并指定过期时间(毫秒)  
 `STRLEN key`		返回字符串长度  
 `INCR key`		数字值增一  
 `INCRBY key increment`		key存储的值加上给定的增量值  
 `INCRBYFLOAT key increment`		key存储的值加上给定的浮点增量值  
 `DECR key`		key存储的数字值减一  
 `DECRBY key decrement`		key存储的值减去给定的减量值  
 `APPEND key value`		key存在并是字符串，将value追加到原值末尾  
### 七、哈希（Hash）
 是String类型的field和value的映射表，适合用于存储对象  
 `HDEL key field1 [field2]`		删除一个或多个哈希表字段  
 `HEXISTS key field`		查看哈希表中指定字段是否存在  
 `HGET key field`		获取存储在哈希表中指定字段的值  
 `HGETALL key`		获取在哈希表中指定key的所有字段和值  
 `HINCRBY key field increment`		为哈希表key中指定字段的整数值加增量increment  
 `HINCRBYFLOAT key field increment`		为哈希表key中指定字段的浮点值加增量increment  
 `HKEYS key` 获取所有哈希表中的字段  
 `HLEN key`	获取哈希表中字段的数量  
 `HMGET key field1 [field2]`	获取所有给定字段的值  
 `HMSET key field1 value1 [field2 value2]`	同时将多个field-value设置到哈希表key中  
 `HSET key field value`	将哈希表key中的字段field设置为value  
 `HSETNX key field value`	字段field不存在时，设置哈希表字段的值  
 `HVALS key`	获取哈希表中所有值  
 `HSCAN key cursor [MATCH pattern] [COUNT count]`	迭代哈希表中的键值对  
### 八、列表（List）
 是简单的字符串列表，按照插入顺序排序，可添加列表的头部或尾部  
 `BLPOP key1 [key2] timeout`	移出并获取列表第一个元素，如果没有元素会阻塞列表直到超时或发现可弹出元素  
 `BRPOP key1 [key2] timeout`	移出并获取列表最后一个元素，如果没有元素会阻塞列表直到超时或发现可弹出元素 
 `BRPOPLPUSH source destination timeout`	列表中弹出一个值，将值插入到另一个列表并返回它，阻塞  
 `LINDEX key index`	通过索引获取列表中的元素  
 `LINSERT key BEFORE|AFTER pivot value`	在列表的pivot前或后插入元素  
 `LLEN key`	获取列表长度  
 `LPOP key`	移出并获取列表的第一个值  
 `LPUSH key value1 [value2]`	将一个或多个值插入到列表头部  
 `LPUSHX key value`	将一个或多个值插入到已存在的列表头部  
 `LRANGE key start stop`	获取列表指定范围内的元素  
 `LREM key count value`	移除列表元素  
 `LSET key index value`	通过索引设置列表元素的值  
 `LTRIM key start stop`	对列表进行修剪，只保留指定区间内的元素  
 `RPOP key`	移除并获取列表最后一个元素  
 `RPOPLPUSH source destination`	移除列表最后一个元素并添加到另一个列表并返回  
 `RPUSH key value1 [value2]`	在列表中添加一个或多个值  
 `RPUSHX key value`	为已存在的列表添加值  
### 九、集合（Set）
 是String类型的无序集合，集合成员是唯一的  
 `SADD key member1 [member2]`	向集合添加一个或多个成员  
 `SCARD key`	获取集合的成员数  
 `SDIFF key1 [key2]`	返回给定所有集合的差集  
 `SDIFFSTORE destination key1 [key2]`	返回给定所有集合的差集并存储在destination中  
 `SINTER key1 [key2]`	返回给定所有集合的交集  
 `SINTERSTORE destination key1 [key2]`	返回给定所有集合的交集并存储在destination中  
 `SISMEMBER key member`	判断member是否是集合key的成员  
 `SMEMBERS key`	返回集合中的所有成员  
 `SMOVE source destination member`	将member元素从source集合移动到destination集合  
 `SPOP key`	移除并返回集合中的一个随机元素  
 `SRANDMEMBER key [count]`	返回集合中一个或多个成员  
 `SUNION key1 [key2]`	返回所有给定集合的并集  
 `SUNIONSTORE destination key1 [key2]`	所有给定集合的并集存储在destination集合中  
 `SSCAN key cursor [MATCH pattern] [COUNT count]`	迭代集合中的元素  
 `SREM key member` 删除元素
### 十、有序集合（ZSET）
 是string类型元素的集合，不允许重复的成员。每个成员关联一个double类型的分数，通过分数为集合成员进行从小到大的排序  
 `ZADD key score1 member1 [score2 member2]`	向有序集合添加一个或多个成员，或更新已有成员的分数  
 `ZCARD key`	获取有序集合的成员数  
 `ZCOUNT key min max`	计算在有序集合中指定区间分数的成员数  
 `ZINCRBY key increment member`	有序集合中对指定成员的分数加上增量increment  
 `ZINTERSTORE destination numberkeys key [key...]`	计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合中  
 `ZLEXCOUNT key min max`	在有序集合中计算指定字典区间内成员数量  
 `ZRANGE key start stop [WITHSCORES]`	通过索引区间返回有序集合  
 `ZRANGEBYLEX key min max [LIMIT offset count]`	通过字典区间返回有序集合的成员  
 `ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT]`	通过分数返回有序集合指定区间内的成员  
 `ZRANK key member`	返回有序集合中指定成员的索引  
 `ZREM key member [member...]`	移除有序集合中的一个或多个成员  
 `ZREMRANGEBYLEX key min max`	移除有序集合中给定的字典区间的所有成员  
 `ZREMRANGEBYRANK key start stop`	移除有序集合中给定的分数区间的所有成员  
 `ZREVRANGE key start stop [WITHSCORES]`	返回有序集合中指定区间内的成员，通过索引，分数从高到低  
 `ZREVRANGEBYSCORE key max min [WITHSCORES]`	返回有序集合中指定分数区间内的成员，分数从高到低  
 `ZREVRANK key member`		返回有序集合中指定成员的排名，有序成员按分数从大到小排序  
 `ZSCORE key member`	返回有序集中成员的分数值  
 `ZUIONSTORE destination numkeys key [key...]`	计算指定的一个或多个有序集的并集，并存储在destination  
 `ZSCAN key cursor [MATCH pattern] [COUNT count]`	迭代有序集合中的元素  
### 十一、HyperLogLog
 用于做基数统计的算法，在输入元素的数量或体积非常大时，计算基数所需空间固定且很小  
 `PFADD key element[element...]`	添加指定元素到HyperLogLog中  
 `PFCOUNT key [key...]`	返回给定HyperLogLog的基数估算值  
 `PFMERGE destkey sourcekey [sourcekey...]`	将多个HyperLogLog合并为一个HyperLogLog  
### 十二、发布订阅(pub/sub)
 一种消息通信模式：发送者（pub）发送消息，订阅者（sub）接收消息  
 `SUBSCRIBE channel [channel...]`		订阅给定的一个或多个频道  
 `UNSUBSCRIBE [channel [channel...]]`		退订给定的频道  
 `PSUBSCRIBE pattern [pattern...]`		订阅一个或多个符合给定模式的频道  
 `PUNSUBSCRIBE [pattern [pattern...]]`		退订所有给定模式的频道  
 `PUBSUB subcommand [argument [argument...]]`		查看订阅与发布系统状态  
 `PUBLISH channel message`	将信息发送到指定频道  
### 十三、事务
 可以一次执行多个命令，且保证：
 + 单独的隔离操作
 + 原子操作
 ```
    开启事务：MULTI
		....
	触发事务：EXEC
	取消事务：DISCARD
 ```
 `WATCH key [key...]`		监视key，如果在事务执行之前key被其他命令修改，事务将被打断  
 `UNWATCH	`	取消WATCH命令对所有key的监视  

### 十四、脚本
 `EVAL script numkeys key [key...] arg [arg...]`	执行Lua脚本  
 `EVALSHA sha1 numkeys key [key...] arg [arg...]`	执行Lua脚本  
 `SCRIPT EXISTS script [script]`	查看指定脚本是否已保存在缓存当中  
 `SCRIPT FLUSH`	从脚本缓存中移除所有脚本  
 `SCRIPT KILL`		杀死当前正在运行的Lua脚本  
 `SCRIPT LOAD script`		将脚本script添加到脚本缓存中，但不立即执行  
### 十五、连接
 `AUTH password`		验证密码是否正确  
 `ECHO message`		打印字符串  
 `PING	`	查看服务是否运行  
 `QUIT	`	关闭当前连接  
 `SELECT index	`	切换到指定的数据库  
### 服务器

## Redis高级
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	