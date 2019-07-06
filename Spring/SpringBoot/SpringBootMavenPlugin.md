## 1.加入插件
 如果要使用Spring Boot Maven插件，我们仅仅需要在`pom.xml`文件中的`<plugins>`下添加对应的XML内容：
 ```
 <?xml version="1.0" encoding="UTF-8"?>
 <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
     <modelVersion>4.0.0</modelVersion>
     <!-- ... -->
     <build>
         <plugins>
             <plugin>
                 <groupId>org.springframework.boot</groupId>
                 <artifactId>spring-boot-maven-plugin</artifactId>
                 <version>1.5.10.RELEASE</version>
                 <executions>
                     <execution>
                         <goals>
                             <goal>repackage</goal>
                         </goals>
                     </execution>
                 </executions>
             </plugin>
         </plugins>
     </build>
 </project>
 ```
 
 这个配置将会重新将在maven生命周期的`package`阶段构建的jar或war重新打包。在`target`目录下，会显示新的打包结果：
 ```
 $ mvn package
 $ ls target/*.jar
 target/myproject-1.0.0.jar target/myproject-1.0.0.jar.original
 ```
 
 如果配置中不添加上述的`<excution/>`配置，可单独运行插件（同时必须执行package）。
 ```
 $ mvn package spring-boot:repackage
 $ ls target/*.jar
 target/myproject-1.0.0.jar target/myproject-1.0.0.jar.original
 ```
## 2.打包可执行jar和war文件
 当`spring-boot-maven-plugin`加入到`pom.xml`文件，插件将自动地尝试重写archives保证他们可执行。可通过`<packaging>`元素来控制构建jar还是war：
 ```
 <?xml version="1.0" encoding="UTF-8"?>
 <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
     <!-- ... -->
     <packaging>jar</packaging>
     <!-- ... -->
 </project>
 ```
 原有的archive文件在`package`阶段会被Spring Boot增强。用于启动的main类可通过配置项执行，或在manifest中添加Main-Class属性。如果未指定，插件会自动搜索带有`public static void main(String[] args)`方法的类。
 如果想构建能够在外部容器中执行和部署的war，我们需要把内置容器依赖设置为`provided`：
 ```
 <?xml version="1.0" encoding="UTF-8"?>
 <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
     <!-- ... -->
     <packaging>war</packaging>
     <!-- ... -->
     <dependencies>
         <dependency>
             <groupId>org.springframework.boot</groupId>
             <artifactId>spring-boot-starter-web</artifactId>
         </dependency>
         <dependency>
             <groupId>org.springframework.boot</groupId>
             <artifactId>spring-boot-starter-tomcat</artifactId>
             <scope>provided</scope>
         </dependency>
         <!-- ... -->
     </dependencies>
 </project>
 ```