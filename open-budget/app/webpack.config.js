const path = require('path');
const webpack = require('webpack');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

const config = {
    entry: {
      app: ["scripts/main.coffee"]
    },
    output: {
        path: __dirname,
        filename: "bundle.js"
    },

    resolve: {
        root: [
          path.resolve(__dirname),
          path.resolve(__dirname, '../node_modules')
        ],

        //When requiring, you don't need to add these extensions
        extensions: ['', '.coffee', '.js'],
        alias: getAlias(),

        //Modules will be searched for in these directories
        modulesDirectories: [
        ],
    },

    resolveLoader: {
      extensions: ['', '.js']
    },

    module: {
      loaders: [
          { test: /\.coffee$/, loader: "coffee-loader" },
          {
            test: /\.hbs$/,
            loader: "handlebars-loader",
            query: {
                helperDirs: [ path.resolve(__dirname, 'scripts/Hasadna/oBudget/Misc/handlebarsHelpers/')]
              }
          },
          {
            test: /\.html/,
            loader: "underscore-template-loader"
          },
          {
            test: /segment-tree-browser\.js$/,
            loader: 'exports?segmentTree'
          },
          {
            test: /bower_components\/pivottable\/dist\/pivot\.js$/,
            loader: 'imports?jqueryUi=jquery-ui'
          },
          {
            test: /bower_components\/typeahead\.js\/dist\/bloodhound\.js/,
            loader: 'exports?Bloodhound'
          },
          {
            test: /[\\\/]bower_components[\\\/]modernizr[\\\/]modernizr\.js$/,
            loader: "imports?this=>window!exports?window.Modernizr"
          },
          {
            test: /bower_components\/bootstrap\/dist\/js\/bootstrap\.js$/,
            loader: "imports?jQuery=jquery"
          },
          {
            test: /numbro\/numbro/,
            loader: "imports?require=>false"
          },

          {
            test: /moment\/moment/,
            loader: "imports?require=>false"
          },
          {
              test: /\.less$/,
              loader: ExtractTextPlugin.extract(
                  'css?-url&sourceMap!' +
                  'less?sourceMap'
              )
          }
      ],

      // prevent webpack to embed all numbero, moment js deps
      //https://github.com/webpack/webpack/issues/198#issuecomment-37306725
      exprContextRegExp: /$^/,
      exprContextCritical: false
    },

    plugins: [
      // makes jquery avaiable in all plugins, for compatibility.
      new webpack.ProvidePlugin({
          $: "jquery",
          jQuery: "jquery",
          "window.jQuery": "jquery"
      }),
      new ExtractTextPlugin('styles/main.css')
      // new webpack.IgnorePlugin(/^\.\/lang$/)
    ],

    debug: true,

    devtool: 'source-map'
};

function getAlias () {

    const alias = {
            "twitter":              "//platform.twitter.com/widgets",
            "hasadna-notifications":"//hasadna-notifications.appspot.com/static/hn",
            "jquery":               "bower_components/jquery/dist/jquery",
            "jquery-ui":            "bower_components/jquery-ui/jquery-ui",
            "bootstrap":            "bower_components/bootstrap/dist/js/bootstrap",
            "modernizr":            "bower_components/modernizr/modernizr",
            "d3":                   "bower_components/d3/d3",
            "d3-tip":               "bower_components/d3-tip/index",
            "underscore":           "bower_components/underscore/underscore",
            "backbone":             "bower_components/backbone/backbone",
            "bloodhound":           "bower_components/typeahead.js/dist/bloodhound",
            "bootstrap-tour":       "bower_components/bootstrap-tour/build/js/bootstrap-tour",
            "pivot":                "bower_components/pivottable/dist/pivot",
            "d3_renderers":         "bower_components/pivottable/dist/d3_renderers",
            "vendor/numbro":        "bower_components/numbro/numbro",
            "vendor/moment":        "bower_components/moment/moment",
            "vendor/bootstrap-select":    "bower_components/bootstrap-select/dist/js/bootstrap-select",
            "ecma_5":               "../node_modules/interval-query/lib/browser/ecma_5",
            "segment-tree-browser": "../node_modules/interval-query/lib/browser/segment-tree-browser",
            "Hasadna/oBudget":       "scripts/Hasadna/oBudget"
    };

    for (var key in alias) {
        if(alias.hasOwnProperty(key)) {
            alias[key] = path.resolve(__dirname, alias[key]);
        }
    }

    return alias;
}

module.exports = config
