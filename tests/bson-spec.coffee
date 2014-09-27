"use strict"
expect = require("expect.js")
ObjectID = require("../src/lib/bson-min.js")

describe "ObjectID", ->
    it "Init", ->
        a = new ObjectID()
        console.log a.toHexString()
        console.log a.toString()
        console.log a.id
        console.log a.inspect()
        console.log a.getTimestamp()
        console.log a.get_inc()
        b = new ObjectID(a.inspect())
        console.log b.inspect()
        expect(a.inspect()).to.be(b.inspect())