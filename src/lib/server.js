// Generated by CoffeeScript 1.8.0
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

define(function(require, exports, module) {
  'use strict';
  var Evemit, Server, Storage;
  Storage = require('lib/storage');
  Evemit = require('lib/evemit');
  Server = (function() {
    function Server(config) {
      this.config = config;
      this.allow = this.config.allow || "*";
      this.deny = this.config.deny || [];
      this.ss = new Storage(true);
      this.ls = new Storage(false);
    }

    Server.prototype.postParent = function(mes, origin) {
      return parent.window.postParent(JSON.stringify(mes), this.origin);
    };


    /* TODO
     *  目前只是简单的判断一下origin是否在allow对应的List里面，只是简单的功能实现
     *  需要讨论实现具体的域白名单和黑名单的解析方案
     */

    Server.prototype.checkOrigin = function(origin) {
      return __indexOf.call(this.allow, origin) >= 0;
    };

    Server.prototype.init = function() {
      var self;
      self = this;
      return Evemit.bind(window, 'message', function(e) {
        var origin, result, storage;
        origin = e.origin;
        if (!self.checkOrigin(origin)) {
          return false;
        }
        result = JSON.parse(e.data);
        storage = result.session ? self.ss : self.ls;
        switch (result.eve.split("|")[0]) {
          case "key":
            return storage.key(result.index, function(data, err) {
              result.data = data;
              result.err = err;
              return self.postParent(result, origin);
            });
          case "size":
            return storage.size(function(data, err) {
              result.data = data;
              result.err = err;
              return self.postParent(result, origin);
            });
          case "setItem":
            return storage.setItem(result.key, result.val, function(err) {
              result.err = err;
              return self.postParent(result, origin);
            });
          case "getItem":
            return storage.getItem(result.key, function(data, err) {
              result.data = data;
              result.err = err;
              return self.postParent(result, origin);
            });
          case "removeItem":
            return storage.removeItem(result.key, function(err) {
              result.err = err;
              return self.postParent(result, origin);
            });
          case "usage":
            return storage.usage(function(data, err) {
              result.data = data;
              result.err = err;
              return self.postParent(result, origin);
            });
        }
      });
    };

    return Server;

  })();
  return module.exports = Server;
});