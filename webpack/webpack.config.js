const webpack = require('webpack');
module.exports = {
	entry: ["./app.js"],				// ��������ļ�
	output: {							// ���ó����ļ�
		path: __dirname,
		filename: "bundle.js"
	},
	module: {							// ����loader
		loaders: [{test: /\.css$/, loader: 'style-loader!css-loader'}]
	},
	plugins: [new webpack.HotModuleReplacementPlugin()],		// �����������ʽ
	devServer: {												// ��webpack-dev-server��������
		contentBase: "./...",		// ���ط��������ĸ�·���ҳ��
		inline: true,				// ����֧��dev-server�Զ�ˢ�µ�����
		hot: true,					// ����webpack����ģ���滻����
		port: '3001',				// �˿ںţ�Ĭ��8080
		proxy: {					// ���ô���
			'/user': {
                target: 'http://localhost:8080/',
                // secure: false,
            }
		}
	}
}