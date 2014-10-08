"use strict"
expect = require("expect.js")
LocalDB = require("../src/localdb.js")
Collection = require("../src/lib/collection.js")

console.log "Test Browser is: ", navigator.userAgent.toLowerCase()

describe "LocalDB", ->
    it "LocalStorage Support", ->
        expect(LocalDB.support().localStorage).to.be(true)
    it "SessionStorage Support", ->
        expect(LocalDB.support().sessionStorage).to.be(true)
    it "IndexedDB Support", ->
        if navigator.userAgent.toLowerCase().indexOf("mozilla") isnt -1
            expect(LocalDB.support().indexedDB).to.be(false)
        else
            expect(LocalDB.support().indexedDB).to.be(true)
    db = new LocalDB('foo', {
        engine: localStorage
        #TODO size && allow
        #size: 500
        #allow: ['baidu.com', 'pt.aliexpress.com','www.qq.com']
    })
    it "new LocalDB", ->
        expect(db instanceof LocalDB).to.be(true)
    it "options", ->
        options = db.options()
        expect(options).to.be.ok()
        expect(options.name).to.be("foo")
        expect(options.engine.toString()).to.be("[object Storage]")
    it "collection", ->
        collection = db.collection("bar")
        collection.insert({a:1})
        expect(collection instanceof Collection).to.be(true)
    it "collections", ->
        collections = db.collections()
        expect(collections).to.be.eql(["bar"])
    it "drop collection", ->
        db.drop("bar")
        collections = db.collections()
        expect(collections).to.be.eql([])
    it "drop db", ->
        bar1 = db.collection("bar1")
        bar2 = db.collection("bar2")
        bar1.insert({a:1})
        bar2.insert({b:2})
        db.drop()
        collections = db.collections()
        expect(collections).to.be.eql([])
    it "timestamp", ->
        console.log LocalDB.getTimestamp("543509d5f3692b00001b2b61")
        expect(LocalDB.getTime("543509d5f3692b00001b2b61")).to.be(1412762069000)

