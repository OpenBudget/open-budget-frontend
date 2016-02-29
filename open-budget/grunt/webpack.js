var webpackConfig = require('../webpack.config.js');
var webpack = require('webpack');

// minify/uglify css/js
webpackConfig.plugins.push(new webpack.optimize.UglifyJsPlugin({comments: false}));

module.exports = {
  main: webpackConfig
};
