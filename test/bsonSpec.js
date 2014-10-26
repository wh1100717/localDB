// Generated by CoffeeScript 1.7.1
define(function(require, exports, module) {
  "use strict";
  var ObjectID;
  ObjectID = require("lib/bson");
  return describe("ObjectID", function() {
    return it("Init", function() {
      var a, b, c, e;
      a = new ObjectID();
      console.log(a.toHexString());
      console.log(a.toString());
      console.log(a.id);
      console.log(a.inspect());
      console.log(a.getTimestamp());
      console.log(a.getTime());
      console.log(a.get_inc());
      b = new ObjectID(a.inspect());
      console.log(b.inspect());
      expect(a.inspect()).toEqual(b.inspect());
      try {
        c = new ObjectID("asdfa");
      } catch (_error) {
        e = _error;
        expect(e.message).toEqual("Argument passed in must be a single String of 12 bytes or a string of 24 hex characters");
      }
      try {
        return c = new ObjectID("aaaaaaaaaaaaaaaaaaaaaaa*");
      } catch (_error) {
        e = _error;
        return expect(e.message).toEqual("Value passed in is not a valid 24 character hex string");
      }
    });
  });
});