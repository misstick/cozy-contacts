// Generated by CoffeeScript 1.8.0
module.exports = {
  slugify: function(text) {
    return text.replace(/[^-a-zA-Z0-9,&\s]+/ig, '').replace(/-/gi, '_').replace(/\s/gi, '-');
  },
  noop: function() {}
};