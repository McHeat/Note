# Spring Boot

## 一、 构建（Build）
 推荐使用支持依赖管理及使用maven中心库的构建工具，如Maven和Gradle。  
 + SpringBoot的每个发行版都会提供支持的依赖清单，示例如下：
 
    ```
    org.springframework.boot:spring-boot-dependencies:1.5.7.RELEASE
    ```
### 1. Maven构建
#### 1.1 通过继承starter parent
 此方法可使用starter的依赖管理和插件管理
 ```
    <!-- Inherit defaults from Spring Boot -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.7.RELEASE</version>
    </parent>
 ```
 通过这种设置，你可以通过在自己的项目中重写属性的方式替换某个依赖
 ```
    <!-- 替换版本 -->
    <properties>
        <spring-data-releasetrain.version>Fowler-SR2</spring-data-releasetrain.version>
    </properties>
 ```
#### 1.2 通过dependencies管理依赖  
 此方法可使用dependencies的依赖管理，但是无法使用插件管理。
 ```
    <dependencyManagement>                                             
        <dependencies>                                                 
            <dependency>                                               
                <!-- Import dependency management from Spring Boot --> 
                <groupId>org.springframework.boot</groupId>            
                <artifactId>spring-boot-dependencies</artifactId>      
                <version>1.5.7.RELEASE</version>                       
                <type>pom</type>                                       
                <scope>import</scope>     <!-- 使用import -->            
            </dependency>                                              
        </dependencies>                                                
    </dependencyManagement>                                            
 ```
 使用这种设置，你将无法通过重写属性方式替换某个依赖。为了达到同样效果，你需要在dependencyManagement标签下`spring-boot-dependecies`实体***之前***添加对应的dependency实体。
#### 1.3 修改Java版本
 `spring-boot-starter-parent`选择了相当保守的Java适配性。可通过`java.version`属性使用其他版本：
 ```
 <properties>
     <java.version>1.8</java.version>
 </properties>
 ``` 
#### 1.4 使用Spring Boot Maven插件
 Spring Boot包含了一个用于打包可执行jar的Maven插件。通过在<plugins>标签下添加来使用：
 ```
 <build>
     <plugins>
         <plugin>
             <groupId>org.springframework.boot</groupId>
             <artifactId>spring-boot-maven-plugin</artifactId>
         </plugin>
     </plugins>
 </build>
 ```
 
### 2. Gradle构建
 不同于Maven，Gradle中不能通过导入parent来共享配置，可以通过在`dependencies`部分中直接导入starters添加依赖：
 ```
 repositories {
     jcenter()
 }
 
 dependencies {
     compile("org.springframework.boot:spring-boot-starter-web:1.5.10.RELEASE")
 }
 ```
`spring-boot-gradle-plugin`提供了创建可执行jar和通过源码运行项目的task。同时也提供了dependency management，这允许你忽略Spring Boot管理的依赖项的版本。
```
plugins {
    id 'org.springframework.boot' version '1.5.10.RELEASE'
    id 'java'
}


repositories {
    jcenter()
}

dependencies {
    compile("org.springframework.boot:spring-boot-starter-web")
    testCompile("org.springframework.boot:spring-boot-starter-test")
}
```