const path = require('path');
const webpack = require('webpack');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const CleanWebpackPlugin = require('clean-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const extractCSS = new ExtractTextPlugin('[name].[contenthash].css');

const config = {
  entry: {
    app: ["app/scripts/main.js"]
  },
  output: {
    path: './dist',
    filename: "bundle.[hash].js"
  },

  resolve: {
    root: [
      path.resolve(__dirname),
      path.resolve(__dirname, 'app')
    ],

    //When requiring, you don't need to add these extensions
    extensions: ['', '.coffee', '.js'],
    alias: getAlias()
  },

  resolveLoader: {
    extensions: ['', '.js']
  },

  module: {
    preLoaders: [
      {
        test: /\.js$/,
        loader: "eslint-loader",
        exclude: /node_modules/
      }
    ],
    loaders: [{
        test: /scripts.*\.js$/,
        loader: "babel-loader"
      }, {
        test: /\.coffee$/,
        loader: "coffee-loader"
      }, {
        test: /\.hbs$/,
        loader: "handlebars-loader",
        query: {
          helperDirs: [path.resolve(__dirname, 'app/scripts/Hasadna/oBudget/Misc/handlebarsHelpers/')]
        }
      },
      {
        // All .html files but index.html
        test: /\.html$/,
        loader: "underscore-template-loader",
        exclude: /index\.html$/
      },
      // see https://github.com/ampedandwired/html-webpack-plugin/issues/301
      {
        test: /index\.html/,
        loader: "html-loader?interpolate=require"
      },
      {
        test: /segment-tree-browser\.js$/,
        loader: 'exports?segmentTree'
      }, {
        test: new RegExp(escapeRegExp(path.join('bower_components', 'pivottable', 'dist', 'pivot.js'))),
        loader: 'imports?jqueryUi=jquery-ui'
      }, {
        test: new RegExp(escapeRegExp(path.join('bower_components', 'typeahead.js', 'dist', 'bloodhound.js'))),
        loader: 'exports?Bloodhound'
      }, {
        test: new RegExp(escapeRegExp(path.join('bower_components', 'bootstrap', 'dist', 'js', 'bootstrap.js'))),
        loader: "imports?jQuery=jquery"
      }, {
        test: new RegExp(escapeRegExp(path.join('numbro', 'numbro'))),
        loader: "imports?require=>false"
      }, {
        test: new RegExp(escapeRegExp(path.join('moment', 'moment'))),
        loader: "imports?require=>false"
      },
      {
          test: /\.(jpg)|(png)|(svg)|(eot)|(woff)|(ttf)$/,
          loader : 'file-loader?name=assets/[name]-[hash].[ext]'
      },
      {
        test: /\.less$/,
        loader: extractCSS.extract(["css-loader?sourceMap", "less-loader?sourceMap"])
      }
    ],

    // prevent webpack to (try) embed all numbero, moment js deps
    noParse: [
      new RegExp(escapeRegExp(path.join('numbro', 'numbro'))),
      new RegExp(escapeRegExp(path.join('moment', 'moment')))
    ]
  },

  plugins: [
    // see https://github.com/ampedandwired/html-webpack-plugin/issues/301
    new HtmlWebpackPlugin({
      template: './app/index.html',
      inject: true,
      hash: true,
      minify: false
    }),
    // makes jquery avaiable in all plugins, for compatibility.
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery"
    }),
    extractCSS,
    // new webpack.IgnorePlugin(/^\.\/lang$/)
    new CleanWebpackPlugin(['dist/*'], {
        root: __dirname,
        verbose: true,
        dry: false
    }),
  ],

  debug: true,

  devtool: 'source-map'
};

function getAlias() {
  const alias = {
    "jquery": "app/bower_components/jquery/dist/jquery",
    "jquery-ui": "app/bower_components/jquery-ui/jquery-ui",
    "bootstrap": "app/bower_components/bootstrap/dist/js/bootstrap",
    "modernizr": "app/bower_components/modernizr/modernizr",
    "d3": "app/bower_components/d3/d3",
    "d3-tip": "app/bower_components/d3-tip/index",
    "underscore": "app/bower_components/underscore/underscore",
    "backbone": "app/bower_components/backbone/backbone",
    "bloodhound": "app/bower_components/typeahead.js/dist/bloodhound",
    "bootstrap-tour": "app/bower_components/bootstrap-tour/build/js/bootstrap-tour",
    "pivot": "app/bower_components/pivottable/dist/pivot",
    "d3_renderers": "app/bower_components/pivottable/dist/d3_renderers",
    "vendor/numbro": "app/bower_components/numbro/numbro",
    "vendor/moment": "app/bower_components/moment/moment",
    "vendor/bootstrap-select": "app/bower_components/bootstrap-select/dist/js/bootstrap-select",
    "segment-tree-browser": "node_modules/interval-query/lib/browser/segment-tree-browser",

    // webpack unable to resolve the deps for this one alone properly
    // So we need to set it to use the bundled version
    "webpack-dev-server/client": "node_modules/webpack-dev-server/client/index.bundle",

    "Hasadna/oBudget": "app/scripts/Hasadna/oBudget"
  };

  return alias;
}

module.exports = config

// from https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
function escapeRegExp(string){
  return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); // $& means the whole matched string
}
