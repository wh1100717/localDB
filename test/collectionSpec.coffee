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
            bar = db.collection("insert")
            bar.insert {
                a: 1
                b: "abc"
                c: /hell.*ld/
                d: {e: 4, f: "5"}
                g: (h) -> return h * 3
                i: [1,2,3]
            }, ->
                bar.find (data) ->
                    data = data[0]
                    expect(data.a).toEqual(1)
                    expect(data.b).toEqual("abc")
                    expect(data.c.test("hello world")).toEqual(true)
                    expect(data.d).toEqual({e:4, f: "5"})
                    expect(Utils.isFunction(data.g)).toEqual(true)
                    expect(data.g(100)).toEqual(300)
                    expect(data.i).toEqual([1,2,3])
        it "InsertPromise", ->
            bar = db.collection("InsertPromise")
            bar.insert({
                a: 1
                b: "abc"
                c: /hell.*ld/
                d: {e: 4, f: "5"}
                g: (h) -> return h * 3
                i: [1,2,3]
            }).then((val) ->
                bar = db.collection("InsertPromise")
                bar.find (data) ->
                    data = data[0]
                    expect(data.a).toEqual(1)
                    expect(data.b).toEqual("abc")
                    expect(data.c.test("hello world")).toEqual(true)
                    expect(data.d).toEqual({e:4, f: "5"})
                    expect(Utils.isFunction(data.g)).toEqual(true)
                    expect(data.g(100)).toEqual(300)
                    expect(data.i).toEqual([1,2,3])
                )
        it "Insert List", ->
            bar = db.collection("insertList")
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
            ], ->
                bar.find (data) ->
                    expect(data.length).toEqual(2)
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
                ], ->
                    bar.find (data) ->
                        expect(data.length).toEqual(4)
        it "InsertListPromise", ->
            bar = db.collection("InsertListPromise")
            bar.insert([
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
            ]).then((val) ->
                bar.find (data) ->
                    expect(data.length).toEqual(2)
                bar.insert([
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
                ]).then((val) ->
                    bar.find (data) ->
                        expect(data.length).toEqual(4)))
        it "Update", ->
            bar = db.collection("update")
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
            }, ->
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
                }, ->
                    bar.find (data) ->
                        data = data[0]
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
                        bar.drop ->
                            bar.insert {
                                a: 1
                            }, ->
                                bar.update {
                                    $set: {
                                        a: 2
                                    }
                                }, {
                                    where: {a:2}
                                }, ->
                                    bar.find (data) ->
                                        data = data[0]
                                        expect(data.a).toEqual(1)
                                        bar.update {
                                            $set: {
                                                b: 2
                                                "b.c": 1
                                            }
                                        }, {
                                            where: {a:1}
                                        }, ->
                                            bar.find (data) ->
                                                data = data[0]
                                                expect(data.b).not.toBeDefined()
                                                bar.update {
                                                    $set: {
                                                        b: 2
                                                        "d.c": 3
                                                    }
                                                }, {
                                                    where: {a: 1}
                                                    upsert: true
                                                }, ->
                                                    bar.findOne (data) ->
                                                        console.log data
                                                        expect(data.b).toEqual(2)
                                                        bar.drop ->
                                                            bar.insert [
                                                                {a:1, b:2}
                                                                {a:1, b:3}
                                                                {a:1, b:4}
                                                            ], ->
                                                                bar.update {
                                                                    $set: {
                                                                        b: 5
                                                                    }
                                                                }, {
                                                                    where: {
                                                                        a: 1
                                                                    }
                                                                    multi: false
                                                                }, ->
                                                                    bar.find (data) ->
                                                                        expect(d.b).not.toEqual(5) for d,index in data  when index > 0
        it "UpdatePromise", ->
            bar = db.collection("UpdatePromise")
            bar.insert([
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ]).then((val) ->
                bar.update {
                    $set: {
                        a:3
                    }
                    $inc: {
                        b: 2
                    }
                }
            ).then((val) ->
                bar.findOne()
            ).then((data) ->
                expect(data.a).toEqual(3)
            )
        it "Remove", ->
            bar = db.collection("remove")
            bar.insert [
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ], ->
                bar.remove ->
                    bar.find (data) ->
                        expect(data).toEqual([])
                        bar.drop ->
                            bar.insert [
                                {a: 1,b: 2}
                                {a: 1,b: 3}
                                {a: 2,b: 4}
                            ], ->
                                bar.remove {
                                    where: {a:1}
                                    multi: false
                                }, ->
                                    bar.find {where: {a: 1}}, (data) ->
                                        expect(data.length).toEqual(1)
                                    bar.drop ->
                                        bar.insert [
                                            {a: 1,b: 2}
                                            {a: 1,b: 3}
                                            {a: 2,b: 4}
                                            {a: 3,b: 4}
                                        ], ->
                                            bar.remove {
                                                where: {a:1}
                                            }, ->
                                                bar.find {where: {a: 1}}, (data) ->
                                                    expect(data.length).toEqual(0)
                                                bar.find (data) ->
                                                    expect(data.length).toEqual(2)
        it "RemovePromise", ->
            bar = db.collection("RemovePromise")
            bar.insert([
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ]).then((val) ->
                bar.remove()
            ).then((val) ->
                bar.find()
            ).then((data) ->
                expect(data).toEqual([])
            )
        it "FindOne", ->
            bar = db.collection('findone')
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
            }], ->
                bar.findOne {where: {a:1}}, (data) ->
                    console.log "findOne: ", data
                    expect(data.a).toEqual(1)
                bar.findOne {where: {no_val: 11111}}, (data) ->
                    expect(data).not.toBeDefined()
        it "FindOnePromise", ->
            bar = db.collection('FindOnePromise')
            bar.insert([{
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
            }]).then((val) ->
                bar.findOne {where: {a:1}})
                .then((val) ->
                    console.log("---------belong----------" + val))
        it "Projection", ->
            bar = db.collection('projection')
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
            }], ->
                bar.findOne {
                    where: {a: 1}
                    projection: {a: 1, _id: -1}
                }, (data) ->
                    expect(data).toEqual({a:1})
                bar.find {
                    where: {a: 1}
                    projection: {"g.$": 1}
                }, (data) ->
                    expect(d.g).toEqual([1]) for d in data
                bar.find {
                    where: {b: 1}
                    projection: {"g.$": 1}
                }, (data) ->
                    expect(data).toEqual([])
                bar.find {
                    where: {a: 1}
                    projection: {"a.$": 1}
                }, (data) ->
                    expect(data).toEqual([])
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
            }], ->
                bar.find {
                    where: { zipcode: "63109"}
                    projection: {
                        _id: 1
                        students: {$elemMatch: { school: 102 } }
                    }
                }, (data) ->
                    console.log data
                bar.find {
                    where: { zipcode: "63109"}
                    projection: {
                        _id: 1
                        unexist: {$elemMatch: { school: 102 } }
                    }
                }, (data) ->
                    console.log data



































