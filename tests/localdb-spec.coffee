expect = require('expect.js')
LocalDB = require('../src/localdb.js')

describe 'LocalDB', ->
    it 'LocalStorage Support', ->
        expect(LocalDB.isSupport()).to.be.ok()
    it 'Init DB', ->
        db = new LocalDB("db_foo")
        expect(db).to.be.a("object")
    it 'Drop DB', ->
        db = new LocalDB("db_foo")
        expect(db.drop()).to.be.ok()
    db = new LocalDB("db_foo")
    it 'Get Collections', ->
        expect(db.collections()).to.be.a("array")
    it 'Get Collection', ->
        collection = db.collection("collection_bar")
        expect(collection).to.be.a("object")
    it 'Drop Collection By DB', ->
        db.drop("collection_bar")
        expect(collection.find().length).to.be(0)
    it 'Drop COllection By Collection', ->
        collection = db.collection("collection_bar")
        collection.drop()
        expect(collection.find().length).to.be(0)
    collection = db.collection("collection_bar")
    it 'Insert Data', ->
        collection.insert({a:1,b:2,c:3,d:{e:4,f:5}})
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
    it 'Update Data', ->
        collection.update {
            $set: {b:4, c:5}
        }, {
            criteria: {
                a: {$gt: 3, $lt: 10},
                d: {
                    e: 4
                }
            }
        }
        expect(collection.find()[6].b).to.be(4)
        expect(collection.find()[6].c).to.be(5)
    it 'find', ->
        data = collection.find {
            criteria: {
                a:{$lt:3},
                b:2
            },
            projection: {
                a: 1,
                b: 1,
                c: 0
            },
            limit: 4
        }
        expect(data).to.be.a("array")
    it 'Fine One Data', ->
        data = collection.findOne {
            criteria: {
                a:{$lt:3}
            }
        }
        console.log data
        expect(data.length).to.be(1 or 0)