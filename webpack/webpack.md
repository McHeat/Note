# webpack # 
## 一、安装

 ```
 npm init
 npm install webpack --save-dev
 ```
 
## 二、配置
 配置文件为`webpack.config.js`：
 1. 引入模块：const webpack = require('webpack');
 2. entry：数组类型，是页面入口文件配置，允许多个入口点。  
   output：输出项配置，入口文件最终生成文件的名字、存放位置
    ```javascript
    {
        entry: ['./src/app'],
        output: {
            path: "dist/js/page",
            filename: "[name].bundle.js"
        }
    }
    ```  
 3. module.loaders告知webpack每一种文件需要使用的加载器
    ```javascript
    module: {
        loaders: [
            {test: /\.css$/, loader: 'style-loader!css-loader'},
            {test: /\.js$/, loader: 'jsx-loder?harmony'}
        ]
    }
    ```
 4. plugins：插件项  
 5. devServer：配置webpack-dev-server
	