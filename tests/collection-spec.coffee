'use strict'
expect = require('expect.js')
LocalDB = require('../src/localdb.js')
Collection = require('../src/lib/collection.js')

db = new LocalDB("foo")

describe 'Collection', ->
    it 'Collection Init', ->
        #第一种collection初始化方式
        collection = db.collection("bar")
        expect(collection).to.be.ok()
        #第二种collection初始化方式
        collection = new Collection("bar", db)
        expect(collection).to.be.ok()
    collection = db.collection("bar")
    it 'Collection insert', ->
        collection.insert({a:1,b:2,c:3,d:{e:"4",f:5}})
        collection.insert({a:2,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:3,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:4,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:5,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:6,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:7,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:8,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:10,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:11,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:12,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:13,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:14,b:2,c:3,d:{e:4,f:5}})
        collection.insert({a:15,b:2,c:3,d:{e:4,f:5}})
        expect(collection.find().length).to.be(14)
    it 'Collection update', ->
        collection.update {
            $set: {b:4, c:5}
        }, {
            criteria: {
                a: {$gt: 0, $lt: 10},
                d: {
                    e: "4"
                }
            }
        }
        expect(collection.find()[0].b).to.be(4)
        expect(collection.find()[0].c).to.be(5)
    it 'Collection find', ->
        data = collection.find({
            criteria: {
                a: {$gt: 1, $lt: 10}
            },
            projection: {
                a: 1,
                b: 1,
                c: 0
            },
            limit: 4
        })
        expect(data).to.be.a("array")

    it 'Collection findOne', ->
        data = collection.findOne(null)
        data = collection.findOne {
            criteria: {
                a:{$lt:3}
            }
        }
        expect(data.length).to.be(1 or 0)
    
    it 'Collection remove', ->
        console.log collection.find()
        collection.remove({
            criteria:{
                a:99
            }
        })
        collection.remove({
            criteria: {
                a: {$gt:3 , $lt: 10}
            }
        })
        console.log collection.find()
        collection.remove(null)
        expect(collection.find().length).to.be(0)
    it 'Collection drop', ->
        collection = db.collection("collection_bar")
        collection.drop()
        expect(collection.find().length).to.be(0)
