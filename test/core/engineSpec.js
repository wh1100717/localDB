// Generated by CoffeeScript 1.8.0
define(function(require, exports, module) {
  "use strict";
  var Engine;
  Engine = require("core/engine");
  return describe("Engine", function() {
    var engine, engineProxy, options, optionsProxy;
    options = {
      expire: "window",
      encrypt: true,
      name: "test"
    };
    optionsProxy = {
      expire: "none",
      encrypt: true,
      name: "test2",
      proxy: "http://localdb.emptystack.net/server.html"
    };
    engine = new Engine(options);
    engineProxy = new Engine(optionsProxy);
    it("Init", function() {
      expect(engine instanceof Engine).toEqual(true);
      return expect(engineProxy instanceof Engine).toEqual(true);
    });
    it("setItem", function() {
      engine.setItem("key123", "value123", function(err) {
        return console.log("Engine setItem err: ", err);
      });
      return engineProxy.setItem("proxy_key123", "proxy_value123", function(err) {
        return console.log("proxy Engine setItem err: ", err);
      });
    });
    it("key", function() {
      engine.key(0, function(key, err) {
        return console.log("Engine key err: ", key, err);
      });
      return engineProxy.key(0, function(key, err) {
        return console.log("proxy Engine key err: ", key, err);
      });
    });
    it("size", function() {
      engine.size(function(size, err) {
        return console.log("Engine size err: ", size, err);
      });
      return engineProxy.size(function(size, err) {
        return console.log("proxy Engine size err: ", size, err);
      });
    });
    it("getItem", function() {
      engine.getItem("key123", function(data, err) {
        return console.log("Engine getItem err: ", data, err);
      });
      return engineProxy.getItem("proxy_key123", function(data, err) {
        return console.log("proxy Engine getItem err: ", data, err);
      });
    });
    it("usage", function() {
      engine.usage(function(usage, err) {
        return console.log("Engine usage err: ", usage, err);
      });
      return engineProxy.usage(function(usage, err) {
        return console.log("proxy Engine usage err: ", usage, err);
      });
    });
    return it("removeItem", function() {
      engine.removeItem("key123", function(err) {
        return console.log("Engine removeItem err: ", err);
      });
      return engineProxy.removeItem("proxy_key123", function(err) {
        return console.log("proxy Engine removeItem err: ", err);
      });
    });
  });
});