'use strict'
expect = require('expect.js')
LocalDB = require('../src/localdb.js')
Collection = require('../src/lib/collection.js')
Where = require('../src/lib/where.js')

db = new LocalDB("foo")

### Where 测试用例原则:
 *  1. 不需要测试迭代过程的中间环节，因此定义的obj应该都为对象，不应该出现数字、字符串、数组等
 *  2. 测试用例要完全覆盖所有代码分支
 *  3. 尽量少用`to.be.ok()`，如果返回值为`true`/`false`，也需要使用`to.be(true/false)`这种格式。
 *  4. 如果有测试用例报错的话，注释加备注再提交请求，或者发个issue。
###

describe 'Where', ->
    it 'Where Comparison equal', ->
        obj = {
            num_val: 1
            str_val: "hello"
            func_val: -> return 100
            regex_val: /he.*ld/
            arr_val: [1,2,3,4]
            arr_val2: ["a","b","c","d","hello World"]
            arr_val3: [/he.*ld/, /just.*do.*it/g]
            obj_val: {e:"4",f:5}
        }
        #值匹配
        expect(Where(obj, {num_val:1})).to.be(true)
        expect(Where(obj, {num_val:2})).to.be(false)
        expect(Where(obj, {arr_val:3})).to.be(true)
        #值为字符串匹配
        expect(Where(obj, {str_val: "hello"})).to.be(true)
        expect(Where(obj, {str_val: ""})).to.be(false)
        expect(Where(obj, {arr_val2: "d"})).to.be(true)

        # # 注意：不提供值为函数的匹配
        # expect(Where(obj, {func_val: -> return 100})).to.be(false)
        #值为正则匹配
        expect(Where(obj, {regex_val: /he.*ld/})).to.be(true)
        expect(Where(obj, {regex_val: /he1.*ld/})).to.be(false)
        expect(Where(obj, {arr_val3: /he1.*ld/})).to.be(false)
        #正则匹配
        expect(Where(obj, {num_val: /\d/})).to.be(true)
        expect(Where(obj, {arr_val: /\d/})).to.be(true)
        expect(Where(obj, {arr_val3: /just.*do.*it/g})).to.be(true)
        #值为数组匹配
        expect(Where(obj, {arr_val: [1,2,3,4]})).to.be(true)
        expect(Where(obj, {arr_val: ["1","2","3","4"]})).to.be(false)
        #值为对象匹配
        expect(Where(obj, {obj_val: {e:"4",f:5}})).to.be(true)
        #key为dot匹配
        expect(Where(obj, {"obj_val.e":"4"})).to.be(true)
        expect(Where(obj, {"obj_val.f":5})).to.be(true)
    it 'Where Comparison gt', ->
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gt":1}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":[{"$gt":1},{"$lt":3}]}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":2,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gt":1}}
        result = Where(obj, where)
        expect(result).to.be(true)
        obj = {"a":0,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gt":1}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Comparison gte', ->
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gte":1}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":2,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gte":1}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":0,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$gte":1}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Comparisongte lt', ->
        obj = {"a":10,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lt":10}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":11,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lt":10}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":9,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lt":10}}
        expect(Where(obj,where)).to.be(true)
    it 'Where Comparisonlte lte', ->
        obj = {"a":10,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lte":10}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":11,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lte":10}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":9,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$lte":10}}
        expect(Where(obj,where)).to.be(true)
    it 'Where Comparison ne', ->
        obj = {"a":10,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$ne":10}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":11,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$ne":10}}
        expect(Where(obj,where)).to.be(true)
    it 'Where Comparison in', ->
        obj = {"a":9,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$in":[10,9,8]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":[9,8],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$in":[[9,8],10,9,8]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$in":[10,11,12]}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":[1,2],"b":4,"c":5}
        where = {"a":{"$in": [5,6,7]}}        
        expect(Where(obj,where)).to.be(false)
    it 'Where Comparison nin', ->
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$nin":[1,2,3]}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$nin":[4,2,3]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":"1","b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$nin":["1","2","3"]}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Logical or', ->
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$or":[{"a":{"$gt":0}},{"b":{"$lt":6}}]}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$or":[{"a":{"$gt":2}},{"b":{"$lt":6}}]}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$or":[{"a":{"$gt":0}},{"b":{"$lt":2}}]}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$or":[{"a":{"$gt":2}},{"b":{"$lt":2}}]}
        expect(Where(obj,where)).to.be(false)
    it 'Where Logical and', ->
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$and":[{"a":{"$gt":0}},{"b":{"$lt":6}}]}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$and":[{"a":{"$gt":2}},{"b":{"$lt":6}}]}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$and":[{"a":{"$gt":0}},{"b":{"$lt":2}}]}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$and":[{"a":{"$gt":2}},{"b":{"$lt":2}}]}
        expect(Where(obj,where)).to.be(false)
    it 'Where Logical not', ->
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$not":{"$lt":0}}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$not":{"$gt":0}}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Logical nor', ->
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$nor":[{"a":5},{"b":4}]}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"$nor":[{"a":1},{"b":5}]}
        expect(Where(obj,where)).to.be(true)
    it 'Where Element exists', ->
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$exists":true}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"z":{"$exists":true}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"z":{"$exists":false}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$exists":false}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Element type', ->
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$type":"number"}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$type":"string"}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":"5","b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$type":"string"}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$type":"eric"}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":5,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"d.e":{"$type":-1}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Evaluation mod', ->
        obj = {"a":0,"b":5,"c":3,"d":{"e":"4","f":5}}
        where = {"a":{"$mod":[2,0]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":4,"b":4,"c":3,"d":{"e":"4","f":5}}
        where = {"a":{"$mod":[2,0]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":5,"c":0,"d":{"e":"4","f":5}}
        where = {"a":{"$mod":[3,2]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":5,"b":5,"c":3,"d":{"e":"4","f":5}}
        where = {"a":{"$mod":[2,0]}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Evaluation regex', ->
        obj = {"a":[1,2,3,4],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":/\d/}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":['1','2','3','4'],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":/\d/}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":'1',"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":/\d/}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":"hello","b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{ "$regex": 'ello'}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":"hello","b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{ "$regex": 'what'}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":/\d/}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":'1',"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":/\b/}
        expect(Where(obj,where)).to.be(true)
    it 'Where Array all', ->
        obj = {"a":[1,2,3],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$all": [1,2]}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":[1,2],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$all": [3,2]}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$all": [3,2]}}
        expect(Where(obj,where)).to.be(false)
    it 'Where Array eleMatch', ->
        obj = {"a":[ { "book": "abc", "price": 8 }, { "book": "xyz", "price": 7 } ],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a": { "$elemMatch": { "book": "xyz", "price": { "$gte": 8 } } }}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a": { "$elemMatch": { "book": "xyz", "price": { "$gte": 8 } } }}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":[ { "book": "abc", "price": 8 }, { "book": "xyz", "price": 9 } ],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a": { "$elemMatch": { "book": "xyz", "price": { "$gte": 8 } } }}
        expect(Where(obj,where)).to.be(true)
    it 'Where Array size', ->
        obj = {"a":[1,2,3],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$size": 3}}
        expect(Where(obj,where)).to.be(true)
        obj = {"a":[1,2,3,4],"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$size": 3}}
        expect(Where(obj,where)).to.be(false)
        obj = {"a":1,"b":4,"c":5,"d":{"e":"4","f":5}}
        where = {"a":{"$size": 1}}
        expect(Where(obj,where)).to.be(false)




