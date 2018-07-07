# 理解Java虚拟机

## 1. 相关概念

 **JDK**：Java程序设计语言、Java虚拟机、Java API类库  
 **JRE**：Java API类库中的Java SE API子集和Java虚拟机  

## 2. Java虚拟机历史
 + Sun Classic/Exact VM：第一款Java虚拟机
 + Sun HotSpot VM：热点代码探测技术
 + Sun Mobile-Embedded VM/Meta-Circular VM：不常用或未商用
 + BEA JRockit VM：专为服务器硬件和服务器端应用场景高度优化的虚拟机，不包含解析器
 + IBM J9 VM：类似于HotSpot，多用途虚拟机
 + Azul VM/BEA Liquid VM：特定硬件平台专有的虚拟机
 + Apache Harmony/Google Android Dalvik VM：
 + Microsoft JVM及其他

## 3. Java未来
 1. 模块化：解决技术平台越来越复杂、庞大的问题  
 2.	多语言平台
 3.	多核并行
 4.	丰富语法

## 4. 编译JDK
 编译环境：Bootstrap JDK、Apache Ant、GCC  
 执行编译：  
 1. 设置环境变量  
     ```
        export LANG=C 		#设定语言选项 
        export ALT_BOOTDIR=${BootstrapJDK路径}
        unset JAVA_HOME 	#取消JAVA_HOME环境变量
        unset CLASSPATH 	#取消CLASSPATH环境变量
     ```
    make sanity检查设置是否正确
 2. 执行编译  
     使用make命令
     编译结果路径：源码下的build/j2sdk-image目录
 3. 编辑env.sh文件  
      默认已设置：JAVA_HOME、CLASSPATH、HOTSPOT_BUILD_USER
      设置虚拟机的环境变量LD_LIBRARY_PATH
      ---------------------------------------------------------------------------------------------
      LD_LIBRARY_PATH=.:${JAVA_HOME}/jre/lib/amd64/native_threads:${JAVA_HOME}/jre/lib/amd64:
      export LD_LIBRARY_PATH
      ----------------------------------------------------------------------------------------------
 4. 启动虚拟机：  
	```../env.sh```

## 5.运行时数据区域
 ![JAVA内存模型](img/Java_mm.png)

 + 程序计数器  
    当前线程所执行的字节码的行号指示器  
    线程私有，各条线程之间计数器互不影响，独立存储  
    唯一没有规定OutOfMemory情况的区域
 + 虚拟机栈  
    线程私有，生命周期与线程相同  
    栈帧：方法执行时创建的内存模型，存储局部变量表、操作数栈、动态链接、方法出口等信息  
    异常：StackOverflowError、OutOfMemoryError    
 + 本地方法栈  
    线程私有，为虚拟机使用到的Native方法服务  
    异常：StackOverflowError、OutOfMemoryError  
 + Java堆（GC堆）  
    所有线程共享的内存区域，在虚拟机启动时创建  
	用于存放几乎所有的对象实例，是垃圾收集器管理的主要区域  
    分类：新生代和老年代  
    TLAB（Thread Local Allocation Buffer）：线程私有的分配缓冲区  
    异常：OutOfMemoryError  
 + 方法区  
    所有线程共享的内存区域  
    存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据  
    异常：OutOfMemoryError  
 + 运行时常量池  
    属于方法区的一部分  
    (1)用于存储Class文件中的常量池信息，即编译期生成的各种字面量和符号引用  
    (2)除了符号引用外，还会存储翻译出的直接引用  
    (3)具备动态性，在运行期间会将新的常量放入  
 + 直接内存  
    堆外内存，然后通过存储在Java堆中的DirectByteBuffer对象作为内存的引用进行操作  
    分配不受Java堆大小限制，受本机总内存大小及处理器寻址空间限制  
    异常：OutOfMemoryError  
## 6. 对象的内存布局
  分为三块区域：对象头(Header)、实例数据(Instance Data)、对齐填充(Padding)  
 + 对象头(Header)  
   - Part1.MarkWord，存储对象自身的运行时数据，是与对象自身定义的数据无关的额外存储成本  
   - Part2.类型指针，即对象指向它的类元数据的指针，可用于确定是哪个类的实例  
 + 实例数据(InstanceData)  
    对象真正存储的有效信息，程序代码中定义的各类型字段内容  
    存储顺序受虚拟机分配策略参数和字段定义顺序影响  
 + 对齐填充(Padding)  
    非必然存在，仅起占位符作用

7.对象的创建（虚拟机遇到new指令时的处理）
	|--	(1)类加载检查。指令的参数在常量池中是否有类的符号引用，及加载、解析和初始化
	|--	(2)为新生对象分配内存。划分方式分为“指针碰撞”和“空闲列表”。
	|		解决并发时内存分配问题：同步处理内存分配动作、使用TLAB
	|		TLAB(本地线程分配缓冲)：每个线程在Java堆中预先分配一小块内存，通过-XX:+/-UseTLAB参数来设定
	|--	(3)将分配到的内存空间初始化为零值。
	|--	(4)对对象进行必要的设置。存储在对象头中的信息，如对象是哪个类的实例、如何找到类的元数据信息、对象的哈希码、GC分代年龄等。
	|--	(5)执行init方法。
8.对象的访问定位
	|--	通过栈上的reference数据来操作堆上的具体对象
	|--	主流的对象访问方式有使用句柄和直接指针两种
	|--	句柄访问：
	|		Java堆中划分内存作为句柄池，reference存储对象的句柄地址
	|		句柄中包含了对象实例数据和类型数据各自的具体地址信息
	|--	直接指针：
	|		对象的布局中放置类型数据的相关信息，reference中直接存储对象地址
9.JVM参数设置
	|--	-Xms：堆的最小值参数
	|--	-Xmx：堆的最大值参数
	|--	-Xmn：新生代的大小
	|--	-Xoss：设置本地方法栈大小（HotSpot虚拟机中无效）
	|--	-Xss：设置栈容量
	|--	-XX:PermSize：方法区大小
	|--	-XX:MaxPermSize：方法区最大值
	|--	-XX:MaxDirectMemorySize：指定直接内存容量，默认与Java堆最大值一致
	|--	-XX:+HeapDumpOnOutOfMemoryError：内存溢出时dump出当前的内存堆转储快照
10.对象存活判断：
	|--	引用计数算法：
	|	|--	方法简单，但无法解决对象之间的相互循环引用问题
	|--	可达性分析算法(实际使用)：
	|	|--	“GC Roots”对象作起点向下搜索，所走过的路径称为引用链。
	|	|--	无引用链相连的对象不可用
	|	|--	可作GC Roots的对象：
	|	|--		虚拟机栈中引用的对象
	|	|--		方法区中类静态属性引用的对象
	|	|--		方法区中常量引用的对象
	|	|--		本地方法栈中JNI(Native方法)引用的对象
	|	|--	过程：
	|	|	(1)对象不可达时会被标记且没覆盖finalize()方法或已被调用，将被放置到F-Queue队列中
	|	|	(2)GC对F-Queue中的对象进行二次小规模标记
	|	|	(3)对象可通过finialize()方法从F-Queue逃脱来避免被回收（仅限一次）
	|	|	(4)对象未逃脱时将会被回收
11.引用扩充
	|--	强引用：强引用存在时永远不会回收被引用的对象
	|--	软引用：有用但并非必需的对象，内存溢出前会进入回收范围
	|--	弱引用：非必需对象，强度弱于软引用，被引用对象只能生存到下一次GC收集前
	|--	虚引用：不会对生存时间构成影响
12.GC回收
	|--	程序计数器、虚拟机栈、本地方法栈随线程生灭，不需要考虑回收
	|--	Java堆和方法区是GC收集器关注的部分
	|--	方法区回收：主要回收废弃常量和无用的类
	|	|--	无用类判断方式：
	|	|--		(1)该类所有的实例已经被回收
	|	|--		(2)加载该类的ClassLoader已被回收
	|	|--		(3)该类对应的java.lang.Class对象没有在任何地方被引用，无法在任何地方通过反射访问该类的方法
	|	|--	类回收参数：
	|	|--		-Xnoclassgc：是否对类进行回收
	|	|--		-verbose:class、-XX:+TraceClassLoading、-XX:+TraceClassUnLoading：查看类加载和卸载信息
13.垃圾收集算法
	|--	标记-清除(Mark-Sweep)算法
	|	|-- 不足：(1)效率问题，两个过程效率都不高 (2)空间问题，大量不连续的内存碎片
	|--	复制算法（商业虚拟机使用，内存非1:1划分）
	|	|--	将内存按容量划分为大小相等的两块，每次只使用其中的一块。当这块内存用完时，将存活对象复制到另一块上，再把已使用的内存一次清空
	|	|--	优点：不需要考虑内存碎片，实现简单，运行高效
	|	|--	不足：内存使用低（可通过内存划分方式减少）
	|--	标记-整理算法（老年代）
	|	|--	标记过程与“标记-清除”算法一样，之后让所有存活的对象向一端移动，然后清理掉端边界以外内存
	|--	分代收集算法
	|	|--	将Java堆分为新生代和老年代，根据各个年代的特点采用最适当的收集算法
	|	|		新生代中每次收集仅有少量对象存活，采用复制算法
	|	|		老年代中对象存活率高、没有额外空间分配担保，使用“标记-清除”或“标记-整理”算法
14.HotSpot的算法实现
	|--	枚举根节点
	|	|--	使用OopMap数据结构直接得知何处存放着对象引用
	|--	安全点
	|	|--	存储OopMap内容变化的指令的位置，程序执行到安全点时暂行开始GC
	|	|--	Part1.选择安全点：以“是否具有让程序长时间执行的特征”为标准
	|	|--		“长时间执行”的特征是指令序列复用，如方法调用、循环跳转、异常跳转等
	|	|--	Part2.所有线程到达安全点停顿
	|	|--		(1)抢先式中断：GC发生时，所有线程全部中断，未在安全点上的线程恢复直到安全点（无虚拟机实现使用）
	|	|--		(2)主动式中断：设置标志，各个线程主动轮询标识，发现中断标志为真时自己中断挂起。
	|	|--			轮询标志地方：和安全点重合，外加创建对象需要分配内存的地方
	|--	安全区域
	|	|--	在一段代码片段中，引用关系不会发生变化。（解决不执行程序无法到安全点中断挂起的情况）
	|	|--	程序执行到SafeRegion中的代码时，标识自身。GC时不再处理这些线程
	|	|--	程序离开SafeRegion时，检查系统是否完成根节点枚举（或GC）。完成则执行，否则等待
15.垃圾收集器
	|--	Serial收集器（新生代）
	|	|--	单线程收集器，进行垃圾收集时必须暂停其他所有的工作线程
	|	|--	Client模式下的默认新生代收集器，简单而高效，可与CMS收集器配合工作
	|	|--	参数：
	|	|		-XX:SurvivorRatio：Eden与Survivor的比例
	|	|		-XX:PretenureSizeThreshold：晋升老年代对象年龄
	|--	ParNew收集器（新生代）
	|	|--	Serial收集器的多线程版本
	|	|--	Server模式下的首选新生代收集器，可与CMS收集器配合工作
	|--	Parallel Scavenge收集器（新生代）
	|	|--	使用复制算法，并行的多线程收集器，关注吞吐量
	|	|--	吞吐量：CPU用于运行用户代码的时间与CPU总消耗时间的比值
	|	|--	参数：
	|	|--		-XX:MaxGCPauseMillis：最大垃圾收集停顿时间
	|	|--		-XX:GCTimeRatio：吞吐量大小，大于0小于100的整数
	|	|--		-XX:+UseAdaptiveSizePolicy：使用GC自适用调节策略
	|--	Serial Old收集器（老年代）
	|	|--	单线程收集器，使用“标记-整理”算法
	|	|--	主要用于Cient模式下使用
	|	|--	Server模式下
	|	|--		作为JDK1.5之前版本与ParallelScavenge收集器搭配
	|	|--		作为CMS收集器的后备预案，在并发收集发生ConcurrentModeFailure时使用
	|--	Parallel Old收集器（老年代）
	|	|--	使用多线程和“标记-整理”算法
	|	|--	JDK1.6后开始提供，为了与Parallel Scavenge配合
	|--	CMS收集器（老年代）
	|	|--	以获取最短回收停顿时间为目标的收集器，基于“标记-清除”算法实现
	|	|--	回收步骤：初始标记、并发标记、重新标记、并发清除
	|	|--	优点：并发收集、低停顿
	|	|--	缺点：对CPU资源非常敏感、无法收集浮动垃圾、收集空间碎片化
	|	|--	参数：
	|	|--		-XX:CMSInitiatingOccupancyFraction：提高触发CMS收集的百分比
	|	|--		-XX:+UseCMSCompactAtFullCollection：用于开启内存碎片的合并整理过程
	|	|--		-XX:CMSGullGCSBeforeCompaction：执行n次不压缩后执行压缩
	|--	G1收集器
	|	|--	将内存“化整为零”，整体基于“标记-整理”算法，局部基于“复制”算法
	|	|--	特点：并行与并发、分代收集、空间整合、可预测的停顿
	|	|--	步骤：初始标记、并发标记、最终标记、筛选回收
16.内存分配与回收策略
	|--	对象优先在Eden分配
	|	|--	大多数情况下，对象在新生代Eden区中分配。当Eden区没有足够空间时，发起MinorGC
	|	|--	虚拟机提供-XX:+PrintGCDetails参数来在发生垃圾收集行为时打印内存回收日志，并且在进程退出时输出当前的内存各区域分配情况
	|--	大对象直接进入老年代
	|	|--	大对象指需要大量连续内存空间的Java对象（避免）
	|	|--	虚拟机提供-XX:PretenureSizeThreshold参数，大于设置值的对象直接在老年代分配
	|--	长期存活的对象将进入老年代
	|	|--	对象每经过MinorGC后仍存活，则Age加1
	|	|--	Eden --(1Age)--> Survivor --(15Age)--> 老年代
	|	|--	虚拟机提供-XX:MaxTenuringThreshold参数设置晋升老年代的年龄阈值
	|--	动态对象年龄判定
	|	|--	同年对象达到Survivor空间的一半时可直接进入老年代
17.空间分配担保
	|--	(1)发生MinorGC之前，检测老年代最大可用连续空间是否大于新生代所有对象总空间
	|--	(2)条件(1)成立时，MinorGC可确保安全
	|--	(3)条件(1)不成立时，查看HandlePromotionFailure设置值是否允许担保失败
	|--	(4)允许担保失败时，继续检查老年代最大可用连续空间是否大于历次晋升到老年代对象平均大小
	|--	(5)最大可用连续空间大于时，尝试MinorGC（有风险）
	|--	(6)小于或HandlePromotionFailure设置不允许时，进行FullGC
18.JDK命令行工具
	|--	jps：虚拟机进程状况工具
	|	|--	列出正在运行的虚拟机进程，显示执行主类名称及进程的本地虚拟机唯一ID
	|	|--	命令格式：jps [options] [hostid]
	|	|--		-q	只输出LVMID，省略主类的名称
	|	|--		-m	输出虚拟机进程启动时传递给主类main()函数的参数
	|	|--		-l	输出主类的全名，执行jar包时输出jar路径
	|	|--		-v	输出虚拟机进程启动时JVM参数
	|--	jstat：虚拟机统计信息监视工具
	|	|--	监视虚拟机各种运行状态信息的命令行工具
	|	|--	命令格式：jstat [option vmid [interval[s|ms] [count]]
	|	|--		-class	监视类装载、卸载数量、总空间以及类装载所耗费的时间
	|	|--		-gc		监视Java堆状况，包括Eden区、两个Survivor区、老年代、永久代等的容量、已用空间、GC时间合计等信息
	|	|--		-gccapacity	同-gc，输出主要关注Java堆各个区域使用到的最大最小空间
	|	|--		-gcutil	输出主要关注已使用空间占总空间的百分比
	|	|--		-gccause	与gcutil基本一致，额外输出导致上一次GC的原因
	|	|--		-gcnew	监视新生代GC状况
	|	|--		-gcnewcapacity	同gcnew，输出主要关注使用到的最大最小空间
	|	|--		-gcold	监视老年代GC状况
	|	|--		-gcoldcapacity	同gcold，输出主要关注使用到的最大最小空间
	|	|--		-gcpermcapacity	输出永久代使用到的最大最小空间（Java8中无效）
	|	|--		-compiler	输出JIT编译器编译过的方法、耗时等消息
	|	|--		-printcompilation	
	|--	jinfo：Java配置信息工具
	|	|--	实时地查看和调整虚拟机各项参数
	|	|--	jinfo [option] pid
	|--	jmap：Java内存映像工具
	|	|--	用于生成堆转储快照（HeapDump或dump文件）
	|	|--	命令格式：jmap [option] vmid
	|	|--		-dump	生成Java堆转储快照
	|	|--		-finalizerinfo	显示在F-Queue中等待Finalizer线程执行finalize方法的对象
	|	|--		-heap	显示Java堆详细信息
	|	|--		-histo	显示堆中对象统计信息
	|	|--		-permstat	以ClassLoader为统计口径显示永久代内存状态
	|	|--		-F	-dump选项无响应时，可强制生成dump
	|--	jhat：虚拟机堆转储快照分析工具
	|	|--	分析jmap生成的堆转储快照
	|--	jstack：Java堆栈跟踪工具
	|	|--	用于生成虚拟机当前时刻的线程快照，用于定位线程出现长时间停顿的原因
	|	|--	命令格式：jstack [option] vmid
	|	|--		-F	当正常输出的请求不被响应时，强制输出线程堆栈
	|	|--		-l	除堆栈外，显示关于锁的附加信息
	|	|--		-m	如果调用到本地方法的话，显示C/C++的堆栈
	|--	HSDIS：JIT生成代码反汇编
	|	|--	通过-XX:+PrintAssembly指令调用HSDIS把动态生成的本地代码还原为汇编代码输出及注释
	|	|--	下载：ProjectKenai网站下载
	|	|--	安装：放到JAVA_HOME/jre/bin/client和JAVA_HOME/jre/bin/server目录中
19.JDK的可视化工具
	|--	JConsole：Java监视与管理控制台
	|	|--	基于JMX的可视化监视、管理工具。
	|	|--	启动：JDK/bin目录下的jconsole.exe启动，自动搜索本机运行的所有虚拟机进程
	|--	VisualVM：多合一故障处理工具
	|	|--	运行监视和故障处理程序
20.高性能硬件部署应用
	|--	通过64位JDK来使用大内存
	|	|--	保证应用程序的FullGC频率控制得足够低（保证对象“朝生夕灭”）
	|	|--	解决内存回收导致的长时间停顿
	|--	使用若干32位虚拟机建立逻辑集群
	|	|--	在一台物理机器上启动多个不同端口的应用服务器进程，前端搭建负载均衡器，反向代理方式分配访问请求
21.类文件结构
	|--	“字节码”存储格式是构成平台无关性的基石
	|--	Class文件是一组以8位字节为基础单位的二进制流，中间没有任何分隔符。
	|--	Java虚拟机规范规定，Class文件格式采用一种类似于C语言结构体的伪结构来存储数据。
	|	|--	无符号数：基本的数据类型
	|	|		以u1、u2、u4、u8分别代表1个字节、2个字节、4个字节、8个字节
	|	|		可用来描述数字、索引引用、数量值或按utf-8编码构成字符串值
	|	|--	表：多个无符号数或者其他表作为数据项构成的复合数据类型
	|	|		表习惯性以“_info”结尾
	|	|		用于描述有层次关系的复合结构的数据
	|							Class文件格式
	|	 ---------------------------------------------------------------------
	|	|	类型			|	名称				|	数量
	|	|	u4				|	magic				|	1
	|	|	u2				|	minor_version		|	1
	|	|	u2				|	major_version		|	1
	|	|	u2				|	constant_pool_count	|	1
	|	|	cp_info			|	constant_pool		|	constant_pool_count-1
	|	|	u2				|	access_flags		|	1
	|	|	u2				|	this_class			|	1
	|	|	u2				|	super_class			|	1
	|	|	u2				|	interfaces_count	|	1
	|	|	u2				|	interfaces			|	interfaces_count
	|	|	u2				|	fields_count		|	1
	|	|	field_info		|	fields				|	fields_count
	|	|	u2				|	methods_count		|	1
	|	|	method_info		|	methods				|	methods_count
	|	|	u2				|	attributes_count	|	1
	|	|	attribute_info	|	attributes			|	attributes_count
	|	 -----------------------------------------------------------------------
	|--	魔数：
	|	|--	Class文件的头4个字节，值为0xCAFEBABE
	|	|--	(唯一)作用：确定文件是否为一个能被虚拟机接收的Class文件
	|--	版本号：Minor和Major
	|--	常量池：
	|	|--	常量池容量计数值（constant_pool_count，类型u2）
	|	|--	常量池（从1开始计数），主要存放两大类常量：
	|	|	(1)字面量Literal：文本字符串、声明为final的常量值等
	|	|	(2)符号引用SymbolicReferences
	|	|		类和接口的全限定名、字段的名称和描述符、方法的名称和描述符
	|	|--	常量池中的每一项常量都是一个表，JDK1.7中共有14种，共同特点是开始第一位是u1类型的标志位
	|--	访问标志：用于识别一些类或接口层次的访问信息，暂时只定义了8个标志位
	|--	类索引(u2)、父类索引(u2)和接口索引集合(u2、u2)
	|	|--	类索引和父类索引各自指向一个类型为CONSTANT_Class_info的类描述常量
	|	|--	接口索引集合入口第一项是接口计数器，表示索引表的容量。之后为接口索引表
	|--	字段表集合
	|	|--	分为字段计数器及字段表两部分。字段包括类级变量以及实例级变量，不包括方法内的局部变量。
	|	|--	字段表结构
	|	|	--------------------------------------------------------------------
	|	|	|	类型			|	名称				|	数量
	|	|	|	u2				|	access_flags		|	1
	|	|	|	u2				|	name_index			|	1						：字段的简单名称
	|	|	|	u2				|	descriptor_index	|	1						：字段和方法的描述符
	|	|	|	u2				|	attributes_count	|	1
	|	|	|	attribute_info	|	attributes			|	attributes_count
	|	|	-------------------------------------------------------------------
	|	|--	全限定名：类全名中“.”替换为“/”，最后加“;”表示结束
	|	|--	简单名称：没有类型和参数修饰的方法或字段名称
	|	|--	描述符：描述字段的数据类型、方法的参数列表和返回值。
	|	|		(1)基本数据类型及void使用一个大写字母
	|	|		(2)对象类型用字符L加对象的全限定名
	|	|		(3)数组类型每一维度使用一个前置的“[”来描述
	|	|		用描述符来描述方法时，先参数列表后返回值的顺序描述
	|--	方法表集合
	|	|--	结构基本同字段表集合
	|	|--	方法里的Java代码，经编译器编译成字节码指令后，存放在方法属性表集合中的名为Code的属性中
	|	|--	特征签名：方法中各个参数在常量池中的字段符号引用的集合
22.属性表集合
	|-- 特点：(1)属性表集合不要求各个属性表具有严格顺序
	|--		  (2)编译器可向属性表中写入自定义属性信息,Java虚拟机忽略不认识的属性
	|				预定义属性9项-->21项
	|--			属性表结构
	|		------------------------------------------------------------------------------
	|		|	类型		|	名称					|	数量
	|		|	u2			|	attribute_name_index	|	1
	|		|	u4			|	attribute_length		|	1
	|		|	u1			|	info					|	attribute_length
	|		------------------------------------------------------------------------------
23.预定义属性（21项）
	|--	Code属性
	|	|--	出现在方法表的属性集合中，非必须属性（接口或抽象类中的方法）
	|	|	Code属性表结构
	|	|	------------------------------------------------------------------------------------
	|	|	|	类型			|	名称					|	数量
	|	|	|	u2				|	attribute_name_index	|	1							常量值固定为Code
	|	|	|	u4				|	attribute_length		|	1							整个属性表长度减掉6个字节
	|	|	|	u2				|	max_stack				|	1							操作数栈深度的最大值
	|	|	|	u2				|	max_locals				|	1							局部变量表所需的存储空间（单位Slot）
	|	|	|	u4				|	code_length				|	1							字节码长度（不允许超过65535条）
	|	|	|	u1				|	code					|	code_length					存储字节码指定的一系列字节流
	|	|	|	u2				|	exception_table_length	|	1
	|	|	|	exception_info	|	exception_table			|	exception_table_length
	|	|	|	u2				|	attributes_count		|	1
	|	|	|	attribute_info	|	attributes				|	attributes_count
	|	|	-------------------------------------------------------------------------------------
	|--	Exceptions属性
	|	|--	作用：列举出方法中可能抛出的受查异常
	|	|				Exceptions属性表结构
	|	|	-------------------------------------------------------------------------------------
	|	|	|	类型			|	名称					|	数量
	|	|	|	u2				|	attribute_name_index	|	1
	|	|	|	u4				|	attribute_length		|	1
	|	|	|	u2				|	number_of_exception		|	1
	|	|	|	u2				|	exception_index_table	|	number_of_exceptions
	|	|	-------------------------------------------------------------------------------------
	|--	LineNumberTable属性
	|	|--	作用：描述Java源码行号与字节行号（字节码的偏移量）之间的对应关系
	|	|				LineNumberTable属性结构
	|	|	-------------------------------------------------------------------------------------
	|	|	|	类型			|	名称					|	数量
	|	|	|	u2				|	attribute_name_index	|	1
	|	|	|	u4				|	attribute_length		|	1
	|	|	|	u2				|	line_number_table_length|	1
	|	|	|	line_number_info|	line_number_table		|	line_number_table_length
	|	|	-------------------------------------------------------------------------------------
	|--	LocalVariableTable属性
	|	|--	作用：描述栈帧中局部变量表中的变量与Java源码中定义的变量之间的关系
	|	|				LocalVariableTable属性结构
	|	|	---------------------------------------------------------------------------------------
	|	|	|	类型				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	local_variable_table_length	|	1
	|	|	|	local_variable_info	|	local_variable_table		|	local_variable_table_length
	|	|	---------------------------------------------------------------------------------------
	|--	SourceFile属性
	|	|--	作用：记录生成Class文件的源码文件名称
	|	|				SourceFile属性结构
	|	|	---------------------------------------------------------------------------------------
	|	|	|	类型				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	sourcefile_index			|	1					：指向常量池中UTF8常量的索引，常量值是源码文件的文件名
	|	|	---------------------------------------------------------------------------------------
	|--	ConstantValue属性
	|	|--	作用：通知虚拟机自动为静态变量赋值，只有static类变量可使用
	|	|--	Java赋值原则：
	|	|		(1)非static变量（实例变量）赋值在实例构造器<init>方法中进行
	|	|		(2)final和static同时修饰的变量且为基本类型或String，使用ConstantValue属性初始化
	|	|		(3)没有final或非基本类型|字符串，使用类构造器<clinit>方法中进行
	|	|						static关键字
	|	|						/	\
	|	|					   是	否
	|	|					  /		  \
	|	|				final关键字	 <init>方法赋值
	|	|					/	\
	|	|				   是	否
	|	|				  /	 	  \
	|	|	基本类型|String	  	   \
	|	|		/ 		\	   		\
	|	|	   是		否			 \
	|	|	  /			  \-----------\-----------><clinit>方法赋值
	|	|	ConstantValue属性赋值
	|	|				ConstantValue属性结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1				：必须固定为2
	|	|	|	u2					|	contantvalue_index			|	1
	|	|	------------------------------------------------------------------------------------------
	|--	InnerClasses属性
	|	|--	作用：记录内部类与宿主类之间的关联
	|	|				InnerClasses属性结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	number_of_classes			|	1
	|	|	|	inner_classes_info	|	inner_classes				|	numer_of_classes
	|	|	------------------------------------------------------------------------------------------
	|	|				inner_classes_info表结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	inner_class_info_index		|	1
	|	|	|	u2					|	outer_class_info_index		|	1
	|	|	|	u2					|	inner_name_index			|	1
	|	|	|	u2					|	inner_class_access_flags	|	1
	|	|	------------------------------------------------------------------------------------------
	|--	Deprecated&Synthetic属性
	|	|--	作用；Deprecated表示类、字段或方法不推荐使用。
	|	|		  Synthetic表示此字段或方法不是由Java源码直接产生，而是由编译器自行添加。
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1			：值必须为0x00000000
	|	|	------------------------------------------------------------------------------------------
	|--	StackMapTable属性
	|	|--	变长属性，位于Code属性的属性表中
	|	|		在虚拟机类加载的字节码验证阶段被新类型检查验证器使用，代替之前比较小号性能的基于数据流分析的类型推导验证器
	|	|				StackMapTable属性结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	number_of_entries			|	1
	|	|	|	stack_map_frame		|	stack_map_frame_entries		|	number_of_entries
	|	|	------------------------------------------------------------------------------------------
	|	|--	一个方法的Code属性中仅可有一个StackMapTable属性，否则抛出ClassFormatError异常
	|--	Signature属性
	|	|--	可选的定长属性，存在于类、属性表和方法表结构的属性表中。
	|	|--	作用：记录泛型签名信息。Java语言的泛型采用的是擦除法实现的伪泛型。
	|	|				Signature属性结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	signature_index				|	1		：必须是一个对常量池的有效索引UTF8
	|	|	------------------------------------------------------------------------------------------
	|--	BootstrapMethods属性
	|	|--	复杂的变长属性，位于类文件的属性表中
	|	|--	作用：保存invokedynamic指令引用的引导方法限定符
	|	|			BootstrapMethods属性结构
	|	|	------------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	attribute_name_index		|	1
	|	|	|	u4					|	attribute_length			|	1
	|	|	|	u2					|	num_bootstrap_methods		|	1			：bootstrap_methods[]数组中的引导方法限定符的数量
	|	|	|	bootstrap_method	|	bootstrap_methods			|	num_bootstrap_methods
	|	|	------------------------------------------------------------------------------------------
	|	|			bootstrap_method属性结构
	|	|	-----------------------------------------------------------------------------------------
	|	|	|	结构				|	名称						|	数量
	|	|	|	u2					|	bootstrap_method_ref		|	1	：指向常量池CONSTANT_MethodHandle结构的索引值
	|	|	|	u2					|	num_bootstrap_arguments		|	1
	|	|	|	u2					|	bootstrap_arguments			|	num_bootstrap_arguments
	|	|	------------------------------------------------------------------------------------------
24.字节码指令
	|--	指令构成：
	|	|--	操作码（Opcode）：一个字节长度的、代表着某种特定操作含义的数字（总数无法超过256条）
	|	|--	操作数（Operands）：跟随其后的零至多个代表此操作所需参数
	|--	Java虚拟机采用面向操作数栈而不是寄存器的架构，大多数指令不包含操作数，只有一个操作码
	|--	Java虚拟机指令集中，大多数指令包含了其操作所对应的数据类型信息
	|	|--	（1）操作码助记符含特殊字符表明专门为哪种数据类型服务
	|	|--	（2）助记符中没有明确地指明操作类型的字母
	|	|--	（3）与数据类型无关的指令
	|	|	大多数对于boolean、byte、short和char类型数据的操作，实际使用相应的int类型作为运算类型
	|--	指令分类：
	|	|--	(1)加载和存储指令：用于将数据在栈帧中的局部变量和操作数栈之间来回传输
	|	|		a.局部变量加载到操作栈：iload[_<n>]|lload[_<n>]|fload[_<n>]|dload[_<n>]|aload[_<n>]
	|	|		b.数值从操作数栈存储到局部变量表：istore[_<n>]|lstore[_<n>]|fstore[_<n>]|dstore[_<n>]|astore[_<n>]
	|	|		c.常量加载到操作数栈：bipush|sipush|ldc[_w]|ldc2_w|aconst_null|iconst_ml|iconst_<i>|lconst_<l>|fconst_<f>|dconst_<d>
	|	|		d.扩充局部变量表索引：wide
	|	|--	(2)运算指令：用于对两个操作数栈上的值进行某种特定运算，并把结果重新存入到操作栈顶
	|	|		a.加法指令：iadd|ladd|fadd|dadd
	|	|		b.减法指令：isub|lsub|fsub|dsub
	|	|		c.乘法指令：imul|lmul|fmul|dmul
	|	|		d.除法指令：idiv|ldiv|fdiv|ddiv
	|	|		e.求余指令：irem|lrem|frem|drem
	|	|		f.取反指令：ineg|lneg|fneg|dneg
	|	|		g.位移指令：ishl|ishr|iushr|lshl|lshr|lushr
	|	|		h.按位或指令：ior|lor
	|	|		i.按位与指令：iand|land
	|	|		j.按位异或指令：ixor|lxor
	|	|		k.局部变量自增指令：iinc
	|	|		l.比较指令：dcmpg|dcmpl|fcmpg|fcmpl|lcmp
	|	|--	(3)类型转换指令：将两种不同的数值类型进行相互转换。
	|	|		a.宽化类型转化(虚拟机直接支持)：int->long|float|double、long->float|double、float->double
	|	|		b.窄化类型转化(显示使用指令)：
	|	|			i2b、i2c、i2s、l2i：简单地丢弃除最低位N个字节以外的内容
	|	|			f2i、f2l、d2i、d2l：浮点值是NaN，转换为int|float类型的0。向零舍入模式取整。
	|	|			d2f：向最接近数舍入模式舍入得到一个可以使用float类型表示的数字
	|	|--	(4)对象创建与访问指令：
	|	|		a.创建类实例：new
	|	|		b.创建数组：newarray|anewarray|multianewarray
	|	|		c.访问类字段和实例字段：getfield|putfield|getstatic|putstatic
	|	|		d.数组元素加载到操作数栈：baload|caload|saload|iaload|laload|faload|daload|aaload
	|	|		e.操作数栈存储到数组元素中：bastore|castore|sastore|iastore|fastore|dastore|aastore
	|	|		f.取数组长度：arraylength
	|	|		g.检验类实例类型：instanceof|checkcast
	|	|--	(5)操作数栈管理指令：
	|	|		a.将操作数栈顶一个或两个元素出栈：pop、pop2
	|	|		b.复制栈顶一个或两个数值并重新压入栈顶：dup、dup2、dup_x1、dup2_x1、dup_x2、dup2_x2
	|	|		c.将栈顶端两个数值互换：swap
	|	|--	(6)控制转移指令：让Java虚拟机有条件或无条件从指定位置指令而不是下一条指令继续执行程序
	|	|		a.条件分支：ifeq|iflt|ifne|ifgt|ifge|ifnull|ifnonnull|if_icmpeq|if_icmpne|if_icmplt|if_icmpgt|if_icmple|if_icmpge|if_acmpge|if_acmpne
	|	|		b.复合条件分支：tableswitch|lookupswitch
	|	|		c.无条件分支：goto|goto_w|jsr|jsr_w|ret
	|	|--	(7)方法调用和返回指令：
	|	|		invokevirtual指令：调用对象的实例方法，根据对象的实际类型进行分派
	|	|		invokeinterface指令：调用接口方法，在运行时搜索实现了接口方法的对象，调用适合的方法
	|	|		invokespecial指令；调用一些需要特殊处理的实例方法，包括实例初始化方法、私有方法和父类方法
	|	|		invokestatic指令：调用类方法
	|	|		invokedynamic指令：在运行时动态解析出调用点限定符所引用的方法并执行
	|	|		方法返回指令：ireturn|lreturn|freturn|dreturn|areturn|return(void方法|实例初始化方法|类和接口的类初始化方法)
	|	|--	(8)异常处理指令
	|	|		a.显式抛出异常：athrow
	|	|		b.运行时异常：在Java虚拟机指令检测到异常状况时自动抛出
	|	|		c.处理异常（catch语句）不是使用字节码指令而是采用异常表处理
	|	|--	(9)同步指令：
	|	|		a.方法级同步：隐式，无需通过字节码指令来控制，实现在方法调用和返回操作中。
	|	|		b.指令序列同步：由synchronized语句块表示，指令序列monitorenter和monitorexit支持synchronized关键字语义
25.虚拟机类加载机制
	|--	虚拟机把描述类的数据从Class文件加载到内存，并对数据进行校验、转换解析和初始化，最终形成可被虚拟机直接使用的Java类型
	|--	类加载的生命周期：
	|		加载、验证、准备、解析、初始化、使用和卸载
	|			 ------------------		
	|					|
	|				   连接
	|--	Java虚拟机执行类的“初始化”情况（有且只有）：
	|	(1)遇到new、getstatic、putstatic或invokestatic字节码且类未初始化时，先触发其初始化。
	|	(2)使用java.lang.reflect包的方法对类进行反射调用且类未初始化时，先触发其初始化。
	|	(3)初始化类但其父类未初始化，先触发父类的初始化。
	|	(4)虚拟机启动时，指定的执行主类需要先初始化。
	|	(5)使用JDK1.7的动态语言支持时，java.lang.invoke.MethodHandle实例最后解析结果REF_getStatic、REF_putStatic、REF_invokeStatic方法句柄且对应类未初始化，先触发其初始化。
	|	以上5种行为称为对一个类进行主动引用。除此之外，所有引用类的方式都不会触发初始化，称为被动引用。
	|-- 类加载的过程：
	|	Part1.加载阶段
	|		(1)通过类的全限定名获取定义此类的二进制字节流
	|		(2)将字节流代表的静态存储结构转化为方法区的运行时数据结构
	|		(3)内存中生成代表此类的java.lang.Class对象（位于方法区），作为方法区类的各种数据的访问入口
	|	Part2.验证阶段
	|		确保Class文件的字节流中包含的信息符合当前虚拟机的要求，且不会危害虚拟机自身的安全
	|		4个检验动作：文件格式验证、元数据验证、字节码验证、符号引用验证
	|	Part3.准备阶段
	|		正式为类变量分配内存并设置类变量初始值的阶段。
	|		如果类字段的字段属性表中存在ConstantValue属性，会被初始化为ConstantValue属性指定的值
	|	Part4.解析阶段
	|		将常量池内的符号引用替换为直接引用。
	|		符号引用：以一组符号来描述所引用的目标，可以是任何形式的字面量
	|		直接引用：直接指向目标的指针、相对偏移量或是一个能间接定位到目标的句柄





















	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	