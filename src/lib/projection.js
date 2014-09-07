// Generated by CoffeeScript 1.7.1
'use strict';
var Projection, Utils;

Utils = require('./utils');

Projection = {};

Projection.generate = function(data, projection) {
  var d, key, p, result, value, _i, _len;
  if (JSON.stringify(projection) === "{}") {
    return data;
  }
  result = [];
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    d = data[_i];
    p = {};
    for (key in projection) {
      value = projection[key];
      if (key.indexOf(".$") !== -1) {
        key = key.split(".")[0];
        console.log(key);
        if (!Utils.isArray(d[key]) || d[key].length === 0) {
          continue;
        }
        p[key] = [d[key][0]];
      } else {
        if (value === 1) {
          p[key] = d[key];
        }
      }
    }
    result.push(p);
  }
  return result;
};

module.exports = Projection;
