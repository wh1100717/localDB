define (require, exports, module) ->

    "use strict"
    LocalDB = require("localdb")
    Collection = require("lib/collection")

    describe "LocalDB", ->
        it "LocalStorage Support", ->
            expect(LocalDB.support().localStorage).toEqual(true)
        it "SessionStorage Support", ->
            expect(LocalDB.support().sessionStorage).toEqual(true)
        it "IndexedDB Support", ->
            if navigator.userAgent.toLowerCase().indexOf("mozilla") isnt -1
                expect(LocalDB.support().indexedDB).toEqual(false)
            else
                expect(LocalDB.support().indexedDB).toEqual(true)
        it "wrong usage", ->
            try
                db = new LocalDB()
            catch e
                expect(e.message).toEqual("dbName should be specified.")
        db = new LocalDB('foo', {
            type: 2
            #TODO size && allow
            #size: 500
            #allow: ['baidu.com', 'pt.aliexpress.com','www.qq.com']
        })
        it "new LocalDB", ->
            expect(db instanceof LocalDB).toEqual(true)
        it "options", ->
            options = db.options()
            expect(options).toBeDefined()
            expect(options.name).toEqual("foo")
            expect(options.type).toEqual(2)
        it "collection", ->
            collection = db.collection("bar")
            collection.insert({a:1})
            expect(collection instanceof Collection).toEqual(true)
        it "collections", ->
            collections = db.collections()
            console.log db.ls.size()
            console.log db.collections()
            expect(collections).toEqual(["bar"])
        it "drop collection", ->
            db.drop("bar")
            collections = db.collections()
            expect(collections).toEqual([])
        it "drop db", ->
            bar1 = db.collection("bar1")
            bar2 = db.collection("bar2")
            bar1.insert({a:1})
            bar2.insert({b:2})
            db.drop()
            collections = db.collections()
            expect(collections).toEqual([])
        it "timestamp", ->
            expect(LocalDB.getTimestamp("543509d5f3692b00001b2b61")).toBeDefined()
            expect(LocalDB.getTime("543509d5f3692b00001b2b61")).toEqual(1412762069000)
        it "window.LocalDB", ->
            expect(typeof window.LocalDB).toBe("undefined")
