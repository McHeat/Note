# Redis配置项

| 名称 | 示例 | 描述 |
| :---: | :---: | :---: |
| 引入文件 |  |  |
| `include` | `include /path/to/local.conf` | 导入其他配置文件。由于在Redis中最后处理的配置命令最终生效，`include`在最前面可被其他配置项覆盖，在最后一行可覆盖其他配置项。 |
| 模块 |  |  |
| `loadmodule` | `loadmodule /path/to/my_module.so` | 在启动阶段加载模块。 |
| 网络 |  |  |
| `bind` | `bind 192.168.1.100 10.0.0.1` | 绑定对外暴露的IP地址，可一次绑定多个。如果未设置该配置项，会暴露Redis服务器所有的IP地址。 |
| `protected-mode` | `protected-mode yes` | 安全保护。当设置为yes时，如果Redis服务器未bind地址或未设置密码，则只能通过本地客户端连接。默认为yes。 |
| `port` | `port 6379` | 对外暴露的端口，默认`6379`。 |
| `tcp-backlog` | `tcp-backlog 511` | TCP监听积压值。在高并发环境中，通过积压避免慢连接问题。在Linux中需要同时修改`/proc/sys/net/core/somaxconn`。 |
| `tcp-keepalive` | `tcp-keepalive 300` | TCP存活时间。用于检测无效端点等。 |
| `unixsocket`
`unixsocketperm` | `unixsocket /tmp/redis.sock`
`unixsocketperm 700` | Unix端口。默认不开启，无法使用unix端口连接。 |
| 通用 |  |  |
| `daemonize` | `daemonize no` | 配置为`yes`启动redis作为守护线程，启动时默认创建`/var/run/redis.pid`。 |
| `supervised ` | `supervised no` | 配置是否与upstart或systemd交互，可选项：`no`、`upstart`、`systemd`、`auto`。 |
| `pidfile ` | `pidfile /var/run/redis_6379.pid` | redis作为守护线程启动时，指定pid文件的位置。 |
| `loglevel` | `loglevel notice` | 指定日志级别，可选项：`debug`、`verbose`、`notice`、`warning`。 |
| `logfile` | `logfile ""` | 指定日志文件名称。空字符串代表标准输出，如守护线程时的`/dev/null`。 |
| `syslog-enabled` | `syslog-enabled no` | 通过设置为`yes`启动系统日志。 |
| `syslog-ident` | `syslog-ident redis` | 设置系统日志的标记。 |
| `syslog-facility` | `syslog-facility local0` | 设置系统日志的场所，只能设置为`USER`或`LOCAL0`-`LOCAL7`。 |
| `databases` | `databases 16` | 设置数据库的数量。默认数据库是0。`SELECT <dbid>`来选择数据库。 |
| `always-show-logo` | `always-show-logo yes` | 总是打印logo，而不限于TTY。 |
| 快照 |  |  |
| `save <seconds> <changes>` | `save 900 1` `save 300 10` `save 60 10000` | 保存数据到硬盘上，当指定的秒数和写操作数达到标准时保存数据库。 |  
| `stop-writes-on-bgsave-error` | `stop-writes-on-bgsave-error yes` | 默认地，在RDB快照开启且最后一次后台保存失败时会停止接受写操作。 |
| `rdbcompression` | `rdbcompression yes` | 在`dump.rdb`文件中通过LZF压缩字符串类型。默认开启，如果想节约CPU资源可关闭。 |
| `rdbchecksum` | `rdbchecksum yes` | 是否检测文件末尾的CRC64校验和，判断文件是否损坏。未开启检验时会保存一个零值提示跳过校验。 |
| `dbfilename` | `dbfilename dump.rdb` | 存储数据库的文件名称。 |
| `dir` | `dir ./` | 工作目录，存储`dbfilename`文件以及AOF文件的目录。 |
| 主从复制 |  |  |
| `replicaof` | `replicaof <masterip> <masterport>` | 作为指定Redis服务器的复制。异步复制、部分重同步、自动复制。 |
| `masterauth` | `masterauth <master-password>` | 设置Redis主服务器的连接密码。 |
| `replica-serve-stale-data` | `replica-serve-stale-data yes` | 当复制服务器与主服务器断开连接时，或复制进程未结束时：设置为`yes`则会继续响应客户端请求，可能数据已过期或为空（初次同步时）;设置为`no`则响应错误信息"SYNC with master in progress"（非数据类型命令除外） |
| `replica-read-only` | `replica-read-only yes` | 设置复制服务器是否接受写命令，从2.6开始默认只读。 |
| `replica-priority` | `replica-priority 100` | 用于在主服务器失效时从复制服务器中选举新的主服务器。较小值的复制服务器会被选为主服务器。零值复制服务器不会被选为主服务器。 |
| `repl-diskless-sync` | `repl-diskless-sync no` | 复制服务器的同步策略：disk或socket（试验性阶段）。新的复制服务器或重新连接但无法恢复同步的复制服务器需要进行全量同步。RDB文件会从主服务器传输到复制服务器，两种传输方式为：`disk-backed`：主服务器创建一个新进程将RDB文件写入到硬盘，然后通过父进程增量地传输给复制服务器。`diskless`：主服务器创建一个新进程，直接将RDB文件传输给复制服务器端口，而不会操作硬盘。 |
| `repl-diskless-sync-delay` | `repl-diskless-sync-delay 5` | 当使用diskless复制模式时，配置主服务器延迟秒数来等待更多的复制服务器连接。 |
| `repl-ping-replica-period` | `repl-ping-replica-period 10` | 复制服务器按照预定义的间隔发送PING命令。该命令修改PING的间隔。 |
| `repl-timeout` | `repl-timeout 60` | 设置复制服务器的超时时间。该值应大于`repl-ping-replica-period`的值。 |
| `repl-disable-tcp-nodelay` | `repl-disable-tcp-nodelay no` | 禁止同步后的备份服务器TCP_NODELAY。设置`yes`则使用数量较小的TPC包和较小的带宽来发送数据到备份服务器，但会导致备份服务器数据更新的延迟；设置为`no`则备份服务器数据更新延迟减小但花费更多的带宽。 |
| `repl-backlog-size` | `repl-backlog-size 1mb` | 设置备份服务器的积压大小。积压是在复制服务器断开连接时暂时存储复制数据的，当复制服务器重新连接时无需全量同步而只需要进行部分重同步。 |
| `repl-backlog-ttl` | `repl-backlog-ttl 3600` | 主服务器一段时间后无复制服务器连接时，释放积压。单位秒。零值代表不释放积压。 |
| `min-replicas-to-write`
`min-replicas-max-lag` | `min-replicas-to-write 3`
`min-replicas-max-lag 10` | 设置主服务器在少于N个复制服务器连接或复制服务器延迟间隔小于等于M秒时，主服务器停止接受写操作。 |
| `replica-announce-ip` `replica-announce-port` | `replica-announce-ip 5.5.5.5` `replica-announce-port 1234` | 复写复制服务器对外展示的ip和端口。 |
| 安全性 |  |  |
| `requirepass` | `requirepass foobared` | 设置客户端执行其他命令前的密码`AUTH <PASSWORD>`。 |
| `rename-command` | `rename-command CONFIG ""` | 重新命名命令，将比较危险的命令修改成其他比较难以猜测的名称。 |
| 客户端 |  |  |
| `maxclients` | `maxclients 10000` | 设置同一时间连接的客户端的最大数量。 |
| 内存管理 |  |  |
| `maxmemory` | `maxmemory <bytes>` | 限定内存大小。当达到内存限制时，Redis会根据驱逐策略移除一部分key。如果无法移除，或策略为`noeviction`，REDIS会响应失败消息，读取命令依然生效。 |
| `maxmemory-policy` | `maxmemory-policy noeviction` | 设置键驱逐策略，可选项为：
`volatile-lru`; `allkeys-lru`; `volatile-lfu`; `allkeys-lfu`; `volatile-random`; `allkeys-random`; `volatile-ttl`; `noeviction`。
LRU-最近最少使用；LFU-最近最不频繁使用 |
| `maxmemory-samples` | `maxmemory-samples 5` | 计算键驱逐策略时的取样大小。 |
| `replica-ignore-maxmemory` | `replica-ignore-maxmemory yes` | 在Redis5中，默认地复制服务器会忽略最大内存限制，键驱逐仅在主服务器上进行处理，然后向复制服务器发送被驱逐键的`DEL`命令。 |
| 懒释放 |  |  |
| `lazyfree-lazy-eviction` | `lazyfree-lazy-eviction no` | 键驱逐时内存是否懒释放：`yes`非阻塞方式，`no`阻塞方式。 |
| `lazyfree-lazy-expire` | `lazyfree-lazy-expire no` | 过期时内存是否懒释放。 |
| `lazyfree-lazy-server-del` | `lazyfree-lazy-server-del no` | 服务器删除时内存是否懒释放。 |
| `replica-lazy-flush` | `replica-lazy-flush no` | 复制时内存是否懒释放。 |
| 追加模式 |  |  |
| `appendonly` | `appendonly no` | 是否启动追加模式，`yes`为启动。AOF与RDB可同时启动。 |
| `appendfilename` | `appendfilename "appendonly.aof"` | AOF文件名称。 |
| `appendfsync` | `appendfsync everysec` | `fsync()`会命令OS将数据立即写入到硬盘，该配置项决定`fsync`的策略：`no`：不执行fsync，由OS决定何时flush，较快。`everysec`：每秒执行一次fsync，速度和安全的折中。`always`：当aof文件有任何的写入时执行fsync，速度慢但最安全。|
| `no-appendfsync-on-rewrite` | `no-appendfsync-on-rewrite no` | 在`BGSAVE`或`BGREWRITEAOF`执行时，是否阻止主线程调用`fsync()`。 |
| `auto-aof-rewrite-percentage`
`auto-aof-rewrite-min-size` | `auto-aof-rewrite-percentage 100`
`auto-aof-rewrite-min-size 64mb` | 当前文件大小与上一次重写文件时的大小比例超过指定比例时，自动重写AOF文件。指定最小文件大小，避免比例达到但文件很小时的重写。 |
| `aof-load-truncated` | `aof-load-truncated yes` | 如果AOF文件在末尾缺失，Redis服务是否启动。设置为`yes`，则Redis服务器继续启动并打印日志通知用户；设置为`no`，则服务器报错并启动失败。 |
| `aof-use-rdb-preamble` | `aof-use-rdb-preamble yes` | 在重写AOF文件时，Redis使用RDB序言以更快地写入和恢复。当开启时，重写的AOF文件会由两部分组成：
`[RDB file][AOF tail]` |
| Lua脚本 |  |  |
| `lua-time-limit` | `lua-time-limit 5000` | 设置Lua脚本的最大执行时长，单位毫秒。当脚本在运行时，仅`SCRIPT KILL`和`SHUTDOWN NOSAVE`命令可用。 |
| Redis集群 |  |  |
| `cluster-enabled` | `cluster-enabled yes` | 启动集群功能。 |
| `cluster-config-file` | `cluster-config-file nodes-6379.conf` | 管理集群节点的集群配置文件，集群配置文件由Redis节点自动创建和更新，每个集群节点需要使用不同的集群配置文件。 |
| `cluster-node-timeout` | `cluster-node-timeout 15000` | 集群节点被视为失败状态的不可达最大毫秒数。 |
| `cluster-replica-validity-factor` | `cluster-replica-validity-factor 10` | 集群复制节点在主服务器失败时故障切换的干扰因素。如果复制节点的数据过期时间大于
(node-timeout * replica-validity-factor) + repl-ping-replica-period的值，则无法进行故障切换。 |
| `cluster-migration-barrier` | `cluster-migration-barrier 1` | 复制节点迁移到孤立主服务器的限制值。孤立主服务器指没有复制节点的主服务器，会导致无法完成故障切换。如果其他主服务器在迁移一个复制节点后剩余复制节点数大于等于指定值，则允许迁移。 |
| `cluster-require-full-coverage` | `cluster-require-full-coverage yes` | 如果hash槽未被覆盖则停止提供查询服务。设置为`no`则集群的子系统依然可以提供服务。 |
| `cluster-replica-no-failover` | `cluster-replica-no-failover no` | 设置为`yes`则可禁止复制服务器在主服务器故障时执行故障切换。设置为`no`则执行故障切换。 |
| `cluster-announce-ip`
`cluster-announce-port`
`cluster-announce-bus-port` | `cluster-announce-ip 10.1.1.5`
`cluster-announce-port 6379`
`cluster-announce-bus-port 6380` | 声明容器等环境中节点的地址、客户端端口、集群消息总线端口。 |
| 慢日志 |  |  |
| `slowlog-log-slower-than` | `slowlog-log-slower-than 10000` | 打印超出指定执行时间的查询请求日志。单位为微秒microsecond。 |
| `slowlog-max-len` | `slowlog-max-len 128` | 慢日志的长度。消耗的内存可通过`SLOWLOG RESET`释放。 |
| 延迟监控 |  |  |
| `latency-monitor-threshold` | `latency-monitor-threshold 0` | 取样分析不同操作来确定延迟来源。单位毫秒。 |
| 事件通知 |  |  |
| `notify-keyspace-events` | `notify-keyspace-events ""` |  |
| 高级配置 |  |  |
| `hash-max-ziplist-entries` | `hash-max-ziplist-entries 512`
 | ziplist格式存储的hash中的最大实例数。超出该值将转为hash。 |
| `hash-max-ziplist-value` | `hash-max-ziplist-value 64` | ziplist格式存储的hash中的最大值。超出该值将转为hash。 |
| `list-max-ziplist-size` | `list-max-ziplist-size -2` | 设置list以ziplist格式存储的限制。可选值：`-5`（64Kb）、`-4`（32Kb）、`-3`（16 Kb）、`-2`（8 Kb）、`-1`（4 Kb）。或其他正数值，代表list中元素个数。 |
| `list-compress-depth` | `list-compress-depth 0` | list压缩模式。0代表不压缩，1、2等代表压缩除首尾的1、2个不压缩，其他执行压缩。 |
| `set-max-intset-entries` | `set-max-intset-entries 512` | 仅针对64位的整数型Set进行优化编码，该值设置Set的最大个数。 |
| `zset-max-ziplist-entries`
`zset-max-ziplist-value` | `zset-max-ziplist-entries 128`
`zset-max-ziplist-value 64` | zset的优化编码设置。 |
| `hll-sparse-max-bytes` | `hll-sparse-max-bytes 3000` | HyperLogLog的稀疏存储和密集存储的限制。 |
| `stream-node-max-bytes`
`stream-node-max-entries` | `stream-node-max-bytes 4096`
`stream-node-max-entries 100` | Stream类型中单个节点的最大字节数，及超过最大元素个数时拆解为新的节点。 |
| `ctiverehashing` | `activerehashing yes` | 每100毫秒CPU时间中的1毫秒对Redis的主hash表执行重哈希。Redis采取的是懒执行：对表的操作越多，重哈希的次数越多。 |
| `client-output-buffer-limit` | `client-output-buffer-limit <class> <hard limit> <soft limit> <soft seconds>` | 客户端输出缓存用于控制未读取服务器数据的客户端断开连接。
`<class>`取值为：`normal`、`replica`和`pubsub`。
当客户端达到`<hard limit>`时会立即断开，或达到`<soft limit>`并持续`<soft seconds>`时长会断开。 |
| `client-query-buffer-limit` | `client-query-buffer-limit 1gb` | 客户端请求缓存可积累新的请求，并默认为一个固定值来避免内存溢出。可通过该配置修改，一般用于`multi/exec`。 |
| `proto-max-bulk-len` | `proto-max-bulk-len 512mb` | 批量请求的限制大小。 |
| `hz` | `hz 10` | Redis后台任务的执行频率，如关闭客户端连接、驱逐过期key等。范围在1到500。值越高，空闲期CPU的使用越高，但超时处理、键过期会更精准。在低延迟要求时可设置较高的值。 |
| `dynamic-hz` | `dynamic-hz yes` | 根据客户端连接数量动态地调整`hz`属性。允许在有过多客户端连接时临时性的动态调升`hz`值。 |
| `aof-rewrite-incremental-fsync` | `aof-rewrite-incremental-fsync yes` | 允许AOF文件重写时每32MB数据执行一次`FSYNC`，增量地写入文件并避免延迟峰值。 |
| `rdb-save-incremental-fsync` | `rdb-save-incremental-fsync yes` | 允许RDB存储时每32MB数据执行一次`FSYNC`，增量地写入文件并避免延迟峰值。 |
| `lfu-log-factor`
`lfu-decay-time` | `lfu-log-factor 10`
`lfu-decay-time 1` | LFU调优参数。 |
| 碎片整理-实验阶段 |  |  |
| `activedefrag` | `activedefrag yes` | 启动碎片整理。 |
| `active-defrag-ignore-bytes` | `active-defrag-ignore-bytes 100mb` | 激活碎片整理的最小碎片大小。 |
| `active-defrag-threshold-lower` | `active-defrag-threshold-lower 10` | 激活碎片整理的最小碎片比例。 |
| `ctive-defrag-threshold-upper` | `active-defrag-threshold-upper 100` | 激活碎片整理的最大比例。 |
| `active-defrag-cycle-min` | `active-defrag-cycle-min 5` | 用于碎片整理的最小CPU周期。 |
| `active-defrag-cycle-max` | `active-defrag-cycle-max 75` | 用于碎片整理的最大CPU周期。 |
| `active-defrag-max-scan-fields` | `active-defrag-max-scan-fields 1000` | 扫描set/zset/hash/list等字段最大数量。 |





