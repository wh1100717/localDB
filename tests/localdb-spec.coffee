'use strict'
expect = require('expect.js')
LocalDB = require('../src/localdb.js')

describe 'LocalDB', ->
    it 'LocalStorage Support', ->
        expect(LocalDB.support()).to.be.ok()
    it 'Init DB', ->
        db = new LocalDB("db_foo")
        expect(db).to.be.a("object")
    it 'Drop DB', ->
        db = new LocalDB("db_foo")
        expect(db.drop()).to.be.ok()
    db = new LocalDB("db_foo")
    it 'Drop Collection By DB', ->
        db.drop("collection_bar")
        expect(collection.find().length).to.be(0)
    it 'Drop COllection By Collection', ->
        collection = db.collection("collection_bar")
        collection.drop()
        expect(collection.find().length).to.be(0)
    collection = db.collection("collection_bar")
    it 'Insert Data', ->
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
        collection.insert [
            {aa:1,bb:2,cc:3},
            {aa:10,bb:"abc",cc:4,dd:111},
            {aaa:111,bbb:222,ccc:333}
        ]
        console.log collection.find()
        expect(collection.find().length).to.be(17)
    it 'Get Collections', ->
        collections = db.collections()
        console.log collections
        expect(db.collections()).to.be.a("array")
    it 'Get Collection', ->
        collection = db.collection("collection_bar")
        expect(collection).to.be.a("object")
    it 'Update Data', ->
        collection.update {
            $set: {b:4, c:5}
        }, {
            where: {
                a: {$gt: 3, $lt: 10},
                "d.e":4
            },
            multi: true
        }
        data = collection.find {
            where: {
                a: {$gt: 3, $lt: 10},
                "d.e":4
            }
        }
        expect(collection.find()[6].b).to.be(4)
        expect(collection.find()[6].c).to.be(5)
    it 'find', ->
        data = collection.find {
            where: {
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
        console.log(data)
        expect(data).to.be.a("array")
    it 'Fine One Data', ->
        data = collection.findOne {
            where: {
                a:{$lt:3}
            }
        }
        expect(data.length).to.be(1 or 0)
    it '$in', ->
        data = collection.find {
            where: {
                a: {$in: [3,4,5]}
            }
        }
        expect(d.a).to.be.within(3, 5) for d in data
    it '$nin', ->
        data = collection.find {
            where: {
                a: {$nin: [3,4,5]}
            }
        }
        expect(d.a).not.to.be.within(3, 5) for d in data
    it '$and', ->
        data = collection.find {
            where: {
                $and: [{b:4},{a:5}]
            }
        }
        expect(d.b).to.be(4) for d in data
    it '$not', ->
        data = collection.find {
            where: {
                b: {
                    $not: 4
                }
            }
        }
        expect(d.b).not.to.be(4) for d in data
    it '$nor', ->
        data = collection.find {
            where: {
                $nor: [{b:4},{a:1},{a:2}]
            }
        }
        for d in data
            expect(d.b).not.to.be(4)
            expect(d.a).not.to.be(1)
            expect(d.a).not.to.be(2)
    it '$or', ->
        data = collection.find {
            where: {
                $or: [{a:1},{a:2}]
            }
        }
        expect(data[0].a).to.be(1 or 2)
    it '$exists', ->
        data = collection.find {
            where: {
                a: {$exists: false}
            }
        }
        expect(d.a?).not.to.be.ok() for d in data
        data = collection.find {
            where: {
                a: {$exists: true}
            }
        }
        expect(d.a?).to.be.ok() for d in data

    it '$exists', ->
        data = collection.find {
            where: {
                a: {$type: "number"},
                b: {$type: "number"},
                d: {$type: "object"},
                "d.e": {$type: "string"}
            }
        }
        expect(data[0].d.e).to.be('4')
    it '$mod', ->
        data = collection.find {
            where: {
                a: {$mod: [4, 0]}
            }
        }
        expect(d.a % 4).to.be(0) for d in data
    it '$regex', ->
        collection.insert({a:15,b:2,c:3,d:{e:4,f:5},g:"Hello World"})
        data = collection.find {
            where: {
                g: {$regex: 'ello'}
            }
        }
        expect(/ello/.test(d.g)).to.be.ok() for d in data
        data = collection.find {
            where: {
                g: /ello/
            }
        }
        expect(/ello/.test(d.g)).to.be.ok() for d in data
        collection.insert({a:15,b:2,c:3,d:{e:4,f:5},g:["Hello World"]})
        data = collection.find {
            where: {
                g: /ello/
            }
        }

    it '$all', ->
        collection.insert({a:1,b:2,c:3,h:[1,2,3,4],i:[[1,2,3],[1,2,4]]})
        data = collection.find {
            where: {
                h: {$all: [1,2]}
            }
        }
        expect(1 in d.h).to.be.ok() for d in data
        expect(2 in d.h).to.be.ok() for d in data
        data = collection.find {
            where: {
                i: {$all: [[1,2]]}
            }
        }
        expect(1 in d.i[0]).to.be.ok() for d in data
        expect(2 in d.i[0]).to.be.ok() for d in data
    it '$elemMatch', ->
        collection.insert({ _id: 1, results: [ { product: "abc", score: 10 }, { product: "xyz", score: 5 } ] })
        collection.insert({ _id: 2, results: [ { product: "abc", score: 8 }, { product: "xyz", score: 7 } ] })
        collection.insert({ _id: 3, results: [ { product: "abc", score: 7 }, { product: "xyz", score: 8 } ] })
        data = collection.find {
            where: { results: { $elemMatch: { product: "xyz", score: { $gte: 8 } } } }
        }
        expect(data).to.be.eql([{"_id":3,"results":[{"product":"abc","score":7},{"product":"xyz","score":8}]}])
    it '$size', ->
        data = collection.find {
            where: {results: {$size: 2}}
        }
        expect(data.length).to.be(3)
    it 'projection $', ->
        collection.insert({ "_id" : 1, "semester" : 1, "grades" : [ 70, 87, 90 ] })
        collection.insert({ "_id" : 2, "semester" : 1, "grades" : [ 90, 88, 92 ] })
        collection.insert({ "_id" : 3, "semester" : 1, "grades" : [ 85, 100, 90 ] })
        collection.insert({ "_id" : 4, "semester" : 2, "grades" : [ 79, 85, 80 ] })
        collection.insert({ "_id" : 5, "semester" : 2, "grades" : [ 88, 88, 92 ] })
        collection.insert({ "_id" : 6, "semester" : 2, "grades" : [ 95, 90, 96 ] })
        data = collection.find {
            where: { semester: 1, grades: { $gte: 85 } },
            projection: {"grades.$": 1}
        }
    it 'projection $elemMatch', ->
        collection.insert  {
            _id: 1,
            zipcode: "63109",
            students: [
                { name: "john", school: 102, age: 10 },
                { name: "jess", school: 102, age: 11 },
                { name: "jeff", school: 108, age: 15 }
            ]
        }
        data = collection.find {
            where: {zipcode: "63109"},
            projection: { students: { $elemMatch: { school: 102 } } }
        }
    it 'update $inc', ->
        collection.insert {
            age: 1
        }
        console.log collection.find {where:{age: {$exists:true}}}
        collection.update {
            $set: {age: 10},
            $inc: {age: 2}
        }
        console.log collection.find {where:{age: {$exists:true}}}
        collection.update {
            age: 100,
            $inc: {age: 2}
        }
        console.log collection.find {where:{age: {$exists:true}}}
    it 'update $mul', ->
        collection.insert { _id: 1, item: "ABC", price: 10.99 }
        console.log collection.find {where: {price: {$exists: true}}}
        collection.update {$mul: {price: 1.25}}
        console.log collection.find {where: {price: {$exists: true}}}
    it 'update $rename', ->
        collection.insert {
            "_id": 1,
            "alias": [ "The American Cincinnatus", "The American Fabius" ],
            "mobile": "555-555-5555",
            "nmae": { "first" : "george", "last" : "washington" }
        }
        collection.update {
            $rename: {"nmae":"name","alias":"nickname"}
        }
        console.log collection.find {where: {nmae: {$exists: true}}}
        console.log collection.find {where: {name: {$exists: true}}}
    it 'update $unset', ->
        collection.insert {
            "_id": 1,
            "alias": [ "The American Cincinnatus", "The American Fabius" ],
            "mobile1": "555-555-5555",
            "nmae": { "first" : "george", "last" : "washington" }
        }
        collection.update {
            $unset: {alias:"",nmae:""}
        }
        console.log collection.find {where: {mobile1: {$exists: true}}}
    it 'update $min && $max', ->
        collection.insert { _id: 1, highScore: 800, lowScore: 200 }
        collection.update {
            $min: { lowScore: 150 },
            $max: { highScore: 1000 }
        }
        console.log collection.find {where: {highScore: {$exists: true}}}






