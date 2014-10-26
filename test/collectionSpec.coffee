define (require, exports, module) ->

    "use strict"
    LocalDB = require("localdb")
    Collection = require("lib/collection")
    Utils = require('lib/utils')


    db = new LocalDB("foo")

    describe "Collection", ->
        it "wrong usage", ->
            try
                bar = db.collection()
            catch e
                expect(e.message).toEqual("collectionName should be specified.")
            
        bar = db.collection("bar")
        it "Init", ->
            expect(bar instanceof Collection).toEqual(true)
        it "Insert", ->
            bar.insert {
                a: 1
                b: "abc"
                c: /hell.*ld/
                d: {e: 4, f: "5"}
                g: (h) -> return h * 3
                i: [1,2,3]
            }
            data = bar.find()[0]
            expect(data.a).toEqual(1)
            expect(data.b).toEqual("abc")
            expect(data.c.test("hello world")).toEqual(true)
            expect(data.d).toEqual({e:4, f: "5"})
            expect(Utils.isFunction(data.g)).toEqual(true)
            expect(data.g(100)).toEqual(300)
            expect(data.i).toEqual([1,2,3])
        it "Insert List", ->
            bar.drop()
            bar.insert [
                {
                    a:1
                    b:2
                    c:3
                },
                {
                    a:2
                    b:3
                    c:4
                }
            ]
            expect(bar.find().length).toEqual(2)
            bar.insert [
                {
                    a:1
                    b:2
                    c:3
                }
                4 #只能插入对象，该数据将被过滤掉，不会被插入
                {
                    a:2
                    b:3
                    c:4
                }
            ]
            expect(bar.find().length).toEqual(4)
        it "Update", ->
            bar.drop()
            bar.insert {
                a: 1
                b: 2
                c: {d: 3, e:4}
                f: (x) -> x * x
                g: [1,2,3,4]
                h: "abc"
                price: 10.99
                max1: 100
                max2: 200
                min1: 50
                min2: 30
                unchanged_val: 100
            }
            bar.update {
                $set: {
                    a:4
                    "c.d": 5
                }
                $inc: {
                    b: 2
                }
                $rename: {f:"function"}
                $unset: {h:""}
                $mul: {price: 1.25}
                $max: {max1:120, max2:150}
                $min: {min1:80, min2: 10}
                unchanged_val: 119 #it will be ignored
            }
            data = bar.find()[0]
            expect(data.a).toEqual(4)
            expect(data.c.d).toEqual(5)
            expect(data.b).toEqual(4)
            expect(data.f).not.toBeDefined()
            expect(Utils.isFunction(data.function)).toEqual(true)
            expect(data.function(9)).toEqual(81)
            expect(data.h).not.toBeDefined()
            expect(data.max1).toEqual(120)
            expect(data.max2).toEqual(200)
            expect(data.min1).toEqual(50)
            expect(data.min2).toEqual(10)
            expect(data.unchanged_val).toEqual(100)
            bar.drop()
            bar.insert {
                a: 1
            }
            bar.update {
                $set: {
                    a: 2
                }
            }, {
                where: {a:2}
            }
            data = bar.find()[0]
            expect(data.a).toEqual(1)
            bar.update {
                $set: {
                    b: 2
                    "b.c": 1
                }
            }, {
                where: {a:1}
            }
            data = bar.find()[0]
            expect(data.b).not.toBeDefined()
            bar.update {
                $set: {
                    b: 2
                    "d.c": 3
                }
            }, {
                where: {a: 1}
                upsert: true
            }
            data = bar.findOne()
            expect(data.b).toEqual(2)
            bar.drop()
            bar.insert [
                {a:1, b:2}
                {a:1, b:3}
                {a:1, b:4}
            ]
            bar.update {
                $set: {
                    b: 5
                }
            }, {
                where: {
                    a: 1
                }
                multi: false
            }
            data = bar.find()
            expect(d.b).not.toEqual(5) for d,index in data  when index > 0
        it "Remove", ->
            bar.drop()
            bar.insert [
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ]
            bar.remove()
            data = bar.find()
            expect(bar.find()).toEqual([])
            bar.drop()
            bar.insert [
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ]
            bar.remove {
                where: {a:1}
                multi: false
            }
            expect(bar.find({where: {a: 1}}).length).toEqual(1)
            bar.drop()
            bar.insert [
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
                {a: 3,b: 4}
            ]
            bar.remove {
                where: {a:1}
            }
            expect(bar.find({where: {a: 1}}).length).toEqual(0)
            expect(bar.find().length).toEqual(2)
        it "FindOne", ->
            bar.drop()
            bar.insert [{
                a: 1
                b: 2
                c: {d: 3, e:4}
                f: (x) -> x * x
                g: [1,2,3,4]
                h: "abc"
                price: 10.99
                max1: 100
                max2: 200
                min1: 50
                min2: 30
            },{
                a: 1
                b: 2
                c: {d: 3, e:4}
                f: (x) -> x * x
                g: [1,2,3,4]
                h: "abc"
                price: 10.99
                max1: 100
                max2: 200
                min1: 50
                min2: 30
            }]
            data = bar.findOne {
                where: {a: 1}
            }
            expect(data.a).toEqual(1)
            data = bar.findOne {
                where: {no_val: 11111}
            }
            expect(data.a).not.toBeDefined()
        it "Projection", ->
            bar.drop()
            bar.insert [{
                a: 1
                b: 2
                c: {d: 3, e:4}
                f: (x) -> x * x
                g: [1,2,3,4]
                h: "abc"
                price: 10.99
                max1: 100
                max2: 200
                min1: 50
                min2: 30
            },{
                a: 1
                b: 2
                c: {d: 3, e:4}
                f: (x) -> x * x
                g: [1,2,3,4]
                h: "abc"
                price: 10.99
                max1: 100
                max2: 200
                min1: 50
                min2: 30
            }]
            data = bar.findOne {
                where: {a: 1}
                projection: {a: 1, _id: -1}
            }
            expect(data).toEqual({a:1})
            data = bar.find {
                where: {a: 1}
                projection: {"g.$": 1}
            }
            expect(d.g).toEqual([1]) for d in data
            data = bar.find {
                where: {b: 1}
                projection: {"g.$": 1}
            }
            expect(data).toEqual([])
            data = bar.find {
                where: {a: 1}
                projection: {"a.$": 1}
            }
            expect(data).toEqual([])
            bar.drop()
            bar.insert [{
                _id: 1,
                zipcode: "63109",
                students: [
                    { name: "john", school: 102, age: 10 },
                    { name: "jess", school: 102, age: 11 },
                    { name: "jeff", school: 108, age: 15 }
                ]
            }
            {
                _id: 2,
                zipcode: "63110",
                students: [
                    { name: "ajax", school: 100, age: 7 },
                    { name: "achilles", school: 100, age: 8 },
                ]
            }
            {
                _id: 3,
                zipcode: "63109",
                students: [
                    { name: "ajax", school: 100, age: 7 },
                    { name: "achilles", school: 100, age: 8 },
                ]
            }
            {
                _id: 4,
                zipcode: "63109",
                students: [
                    { name: "barney", school: 102, age: 7 },
                    { name: "ruth", school: 102, age: 16 },
                ]
            }]
            data = bar.find {
                where: { zipcode: "63109"}
                projection: {
                    _id: 1
                    students: {$elemMatch: { school: 102 } }
                }
            }
            console.log data
            data = bar.find {
                where: { zipcode: "63109"}
                projection: {
                    _id: 1
                    unexist: {$elemMatch: { school: 102 } }
                }
            }
            console.log data



































