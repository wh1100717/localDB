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
            insert_bar = db.collection("insert")
            insert_bar.insert {
                a: 1
                b: "abc"
                c: /hell.*ld/
                d: {e: 4, f: "5"}
                g: (h) -> return h * 3
                i: [1,2,3]
            }, ->
                insert_bar.find (data) ->
                    data = data[0]
                    expect(data.a).toEqual(1)
                    expect(data.b).toEqual("abc")
                    expect(data.c.test("hello world")).toEqual(true)
                    expect(data.d).toEqual({e:4, f: "5"})
                    expect(Utils.isFunction(data.g)).toEqual(true)
                    expect(data.g(100)).toEqual(300)
                    expect(data.i).toEqual([1,2,3])
        it "InsertPromise", ->
            InsertPromise_bar = db.collection("InsertPromise")
            InsertPromise_bar.drop()
                .then( -> InsertPromise_bar.find())
                .then( (data) -> console.log "InsertPromise --->", data.length)
                .then( ->
                    InsertPromise_bar.insert {
                        a: 1
                        b: "abc"
                        c: /hell.*ld/
                        d: {e: 4, f: "5"}
                        g: (h) -> return h * 3
                        i: [1,2,3]
                    }
                )
                .then( -> InsertPromise_bar.find())
                .then( (data) ->
                    console.log data.length, data[0]
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
            insertList_bar = db.collection("insertList")
            insertList_bar.drop ->
                insertList_bar.insert [
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
                    insertList_bar.find (data) ->
                        expect(data.length).toEqual(2)
                    insertList_bar.insert [
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
                        insertList_bar.find (data) ->
                            expect(data.length).toEqual(4)
        it "InsertListPromise", ->
            InsertListPromise_bar = db.collection("InsertListPromise")
            InsertListPromise_bar.drop()
                .then( ->
                    InsertListPromise_bar.insert [
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
                )
                .then( ->
                    InsertListPromise_bar.find()
                )
                .then( (data) ->
                    expect(data.length).toEqual(2)
                    InsertListPromise_bar.insert [
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
                )
                .then( ->
                    InsertListPromise_bar.find()
                )
                .then( (data) ->
                    expect(data.length).toEqual(4)
                )
        it "Update", ->
            update_bar = db.collection("update")
            update_bar.insert {
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
                update_bar.update {
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
                    update_bar.find (data) ->
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
                        update_bar.drop ->
                            update_bar.insert {
                                a: 1
                            }, ->
                                update_bar.update {
                                    $set: {
                                        a: 2
                                    }
                                }, {
                                    where: {a:2}
                                }, ->
                                    update_bar.find (data) ->
                                        data = data[0]
                                        expect(data.a).toEqual(1)
                                        update_bar.update {
                                            $set: {
                                                b: 2
                                                "b.c": 1
                                            }
                                        }, {
                                            where: {a:1}
                                        }, ->
                                            update_bar.find (data) ->
                                                data = data[0]
                                                expect(data.b).not.toBeDefined()
                                                update_bar.update {
                                                    $set: {
                                                        b: 2
                                                        "d.c": 3
                                                    }
                                                }, {
                                                    where: {a: 1}
                                                    upsert: true
                                                }, ->
                                                    update_bar.findOne (data) ->
                                                        console.log data
                                                        expect(data.b).toEqual(2)
                                                        update_bar.drop ->
                                                            update_bar.insert [
                                                                {a:1, b:2}
                                                                {a:1, b:3}
                                                                {a:1, b:4}
                                                            ], ->
                                                                update_bar.update {
                                                                    $set: {
                                                                        b: 5
                                                                    }
                                                                }, {
                                                                    where: {
                                                                        a: 1
                                                                    }
                                                                    multi: false
                                                                }, ->
                                                                    update_bar.find (data) ->
                                                                        expect(d.b).not.toEqual(5) for d,index in data  when index > 0
        it "UpdatePromise", ->
            UpdatePromise_bar = db.collection("UpdatePromise")
            UpdatePromise_bar.drop()
                .then( ->
                    UpdatePromise_bar.insert [
                        {a: 1,b: 2}
                        {a: 1,b: 3}
                        {a: 2,b: 4}
                    ]
                )
                .then( ->
                    UpdatePromise_bar.update {
                        $set: {
                            a:3
                        }
                        $inc: {
                            b: 2
                        }
                    }
                )
                .then( ->
                    UpdatePromise_bar.findOne()
                )
                .then( (data) ->
                    expect(data.a).toEqual(3)
                )
        it "Remove", ->
            remove_bar = db.collection("remove")
            remove_bar.insert [
                {a: 1,b: 2}
                {a: 1,b: 3}
                {a: 2,b: 4}
            ], ->
                remove_bar.remove ->
                    remove_bar.find (data) ->
                        expect(data).toEqual([])
                        remove_bar.drop ->
                            remove_bar.insert [
                                {a: 1,b: 2}
                                {a: 1,b: 3}
                                {a: 2,b: 4}
                            ], ->
                                remove_bar.remove {
                                    where: {a:1}
                                    multi: false
                                }, ->
                                    remove_bar.find {where: {a: 1}}, (data) ->
                                        expect(data.length).toEqual(1)
                                    remove_bar.drop ->
                                        remove_bar.insert [
                                            {a: 1,b: 2}
                                            {a: 1,b: 3}
                                            {a: 2,b: 4}
                                            {a: 3,b: 4}
                                        ], ->
                                            remove_bar.remove {
                                                where: {a:1}
                                            }, ->
                                                remove_bar.find {where: {a: 1}}, (data) ->
                                                    expect(data.length).toEqual(0)
                                                remove_bar.find (data) ->
                                                    expect(data.length).toEqual(2)
        it "RemovePromise", ->
            RemovePromise_bar = db.collection("RemovePromise")
            RemovePromise_bar.drop()
                .then( ->
                    RemovePromise_bar.insert [
                        {a: 1,b: 2}
                        {a: 1,b: 3}
                        {a: 2,b: 4}
                    ]
                )
                .then( -> RemovePromise_bar.remove())
                .then( -> RemovePromise_bar.find())
                .then( (data) -> expect(data).toEqual([]))
        it "FindOne", ->
            findone_bar = db.collection('findone')
            findone_bar.insert [{
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
                findone_bar.findOne {where: {a:1}}, (data) ->
                    console.log "findOne: ", data
                    expect(data.a).toEqual(1)
                findone_bar.findOne {where: {no_val: 11111}}, (data) ->
                    expect(data).not.toBeDefined()
        it "FindOnePromise", ->
            FindOnePromise_bar = db.collection('FindOnePromise')
            FindOnePromise_bar.drop()
                .then( ->
                    FindOnePromise_bar.insert [
                        {
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
                        }
                    ]
                )
                .then( -> FindOnePromise_bar.findOne {where: {a:1}})
                .then( (data) -> expect(data.a).toEqual(1))
        it "Projection", ->
            projection_bar = db.collection('projection')
            projection_bar.insert [{
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
                projection_bar.findOne {
                    where: {a: 1}
                    projection: {a: 1, _id: -1}
                }, (data) ->
                    expect(data).toEqual({a:1})
                projection_bar.find {
                    where: {a: 1}
                    projection: {"g.$": 1}
                }, (data) ->
                    expect(d.g).toEqual([1]) for d in data
                projection_bar.find {
                    where: {b: 1}
                    projection: {"g.$": 1}
                }, (data) ->
                    expect(data).toEqual([])
                projection_bar.find {
                    where: {a: 1}
                    projection: {"a.$": 1}
                }, (data) ->
                    expect(data).toEqual([])
            projection2_bar = db.collection("projection2")
            projection2_bar.insert [{
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
                    { name: "baney", school: 102, age: 7 },
                    { name: "ruth", school: 102, age: 16 },
                ]
            }], ->
                projection2_bar.find {
                    where: { zipcode: "63109"}
                    projection: {
                        _id: 1
                        students: {$elemMatch: { school: 102 } }
                    }
                }, (data) ->
                    console.log data
                projection2_bar.find {
                    where: { zipcode: "63109"}
                    projection: {
                        _id: 1
                        unexist: {$elemMatch: { school: 102 } }
                    }
                }, (data) ->
                    console.log data



































