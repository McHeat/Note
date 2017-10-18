const webpack = require('webpack');
module.exports = {
	entry: ["./app.js"],				// 设置入口文件
	output: {							// 设置出口文件
		path: __dirname,
		filename: "bundle.js"
	},
	module: {							// 配置loader
		loaders: [{test: /\.css$/, loader: 'style-loader!css-loader'}]
	},
	plugins: [new webpack.HotModuleReplacementPlugin()],		// 插件，数组形式
	devServer: {												// 对webpack-dev-server进行配置
		contentBase: "./...",		// 本地服务器在哪个路径搭建页面
		inline: true,				// 用来支持dev-server自动刷新的配置
		hot: true,					// 启动webpack的热模块替换特性
		port: '3001',				// 端口号，默认8080
		proxy: {					// 设置代理
			'/user': {
                target: 'http://localhost:8080/',
                // secure: false,
            }
		}
	}
}