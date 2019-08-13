# Docker
### 二、镜像
#### 最小镜像
 hello-world是Docker官方提供的一个镜像，用来验证Docker是否安装成功。  
 1. 通过`docker pull`从Docker Hub下载镜像
	```
	docker pull hello-world
	```  
	通过`docker iamges hello-world`命令查看镜像信息，显示镜像不到2KB。
 2. 通过`docker run`运行
	```
	docker run hello-world
	```
 hello-world的Dockerfile内容：  
 ```
 FROM scratch	# 镜像从0开始构建  
 COPY hello /	# 将文件“hello”复制到镜像的根目录  
 CMD ["/hello"]	# 容器启动时，执行/hello  
 ```
#### base镜像
 提供一个基本的操作系统环境，用户可根据需要安装和配置软件的镜像。base镜像的含义：  
 + 不依赖其他镜像，从scratch构建
 + 其他镜像以之为基础进行扩展
 base镜像通常都是各种Linux发行版的Docker镜像。
 
#### 镜像的分层结构
 Docker支持通过扩展现有镜像，创建新的镜像。新镜像是从base镜像一层一层叠加生成，每安装一个软件，就在现有镜像的基础上增加一层。  
 Docker镜像采用分层结构的好处是**共享资源**。Docker Host只需在磁盘上保存一份base镜像，内存也只需要加载一份base镜像，就可为所有容器服务。
 如果多个容器共享一份基础镜像，某个容器对基础镜像的内容修改会被限制在单个容器中。
 
#### 可写的容器层
 当容器启动时，一个新的可写层被加载到镜像的顶部，通常被称为“容器层”，“容器层”之下的都叫“镜像层”。
 所有对容器的改动都只会发生在容器层中。只有容器层是可写的，容器层下面的所有镜像层都是只读的。
 在容器层中，用户看到的是一个叠加后的文件系统，只有当需要修改时才复制一份数据到容器层，这种特性被称作Copy-on-Write。
 
#### 构建镜像
 建议使用现成的镜像，可省去自己做镜像的工作量和利用前人的经验。当找不到现成镜像或需要加入特定功能时，我们就需要自己构建镜像了。  
 Docker提供了两种构建镜像的方法：
 + docker commit命令
 + Dockerfile构建文件
###### docker commit
 docker commit命令是创建新镜像最直观的方法，过程包括三个步骤：
 1. 运行容器
 2. 修改容器
 3. 将容器保存为新的镜像
 
###### Dockerfile构建镜像
 `docker build`命令构建镜像，`-t`将新镜像命名，末尾`.`指明build context为当前目录。
 Docker默认从build context中查找Dockerfile文件，可通过`-f`参数指定Dockfile的位置。
 Docker会将build context中的所有文件发送给Docker Daemon，build context为镜像构建提供所需的文件或目录。
 Dockfile中的ADD、COPY等命令可将build context中的文件添加到镜像。

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 