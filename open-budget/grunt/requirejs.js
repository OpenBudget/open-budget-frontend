module.exports = {
  compile: {
    // !! You can drop your app.build.js config wholesale into 'options'
    options: {
      baseUrl: "app",
      name: "scripts/main",
      out: "dist/scripts/main.js",
      optimize: 'uglify2',
      // Uncomment to debug
      //optimize: 'none',
      mainConfigFile:'app/scripts/config.js',
      paths: {
          main: "scripts/main",
          "hasadna-notifications": 'empty:'
      },
      logLevel: 0,
      findNestedDependencies: false,
      inlineText: true,
      preserveLicenseComments: false,
      generateSourceMaps: true,
      useSourceUrl: true
    }
  }
};
