module.exports = {
  compile: {
      options: {
    processName: function(name) {
        name = name.split('/');
        name = name[name.length-1];
        name = name.substring(0,name.length-5);
        name = name.replace(/-/g,"_");
        return name;
    }
      },
      files: {
    "<%= yeoman.app %>/scripts/templates.js": ["<%= yeoman.app %>/templates/*.html"]
      }
  }
};