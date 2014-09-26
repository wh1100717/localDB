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
    obj = {
            "a":1,
            "b":4,
            "c":[[5],10],
            "d":{
                "e":"4",
                "f":5
                },
            "e":"1",
            "f":5,
            "g":0,
            "h":[1,2,3],
            "i":'hello',
            "j":[ { "book": "abc", "price": 8 }, { "book": "xyz", "price": 7 } ]
            }
    it 'Where Comparison gt', ->
        expect(Where(obj,{"a":{"$gt":1}})).to.be(false)
        expect(Where(obj,{"a":[{"$gt":1},{"$lt":3}]})).to.be(false)
        expect(Where(obj,{"a":{"$gt":0}})).to.be(true)
        expect(Where(obj,{"a":{"$gt":2}})).to.be(false)
    it 'Where Comparison gte', ->
        expect(Where(obj,{"a":{"$gte":1}})).to.be(true)
        expect(Where(obj,{"a":{"$gte":0}})).to.be(true)
        expect(Where(obj,{"a":{"$gte":2}})).to.be(false)
    it 'Where Comparisongte lt', ->
        expect(Where(obj,{"b":{"$lt":4}})).to.be(false)
        expect(Where(obj,{"b":{"$lt":3}})).to.be(false)
        expect(Where(obj,{"b":{"$lt":10}})).to.be(true)
    it 'Where Comparisonlte lte', ->
        expect(Where(obj,{"b":{"$lte":4}})).to.be(true)
        expect(Where(obj,{"b":{"$lte":3}})).to.be(false)
        expect(Where(obj,{"b":{"$lte":5}})).to.be(true)
    it 'Where Comparison ne', ->
        expect(Where(obj,{"a":{"$ne":1}})).to.be(false)
        expect(Where(obj,{"a":{"$ne":2}})).to.be(true)
    it 'Where Comparison in', ->
        expect(Where(obj,{"a":{"$in":[1,9,8]}})).to.be(true)
        expect(Where(obj,{"c":{"$in":[5,9,8]}})).to.be(false)
        expect(Where(obj,{"c":{"$in":[[5],8,9]}})).to.be(true)
        expect(Where(obj,{"a":{"$in":[10,11,12]}})).to.be(false)
        expect(Where(obj,{"c":{"$in":[5,6,7]}})).to.be(false)
    it 'Where Comparison nin', ->
        expect(Where(obj,{"a":{"$nin":[1,2,3]}})).to.be(false)
        expect(Where(obj,{"a":{"$nin":[4,2,3]}})).to.be(true)
        expect(Where(obj,{"e":{"$nin":["1","2","3"]}})).to.be(false)
    it 'Where Logical or', ->
        expect(Where(obj,{"$or":[{"a":{"$gt":0}},{"b":{"$lt":6}}]})).to.be(true)
        expect(Where(obj,{"$or":[{"a":{"$gt":2}},{"b":{"$lt":6}}]})).to.be(true)
        expect(Where(obj,{"$or":[{"a":{"$gt":0}},{"b":{"$lt":2}}]})).to.be(true)
        expect(Where(obj,{"$or":[{"a":{"$gt":2}},{"b":{"$lt":2}}]})).to.be(false)
    it 'Where Logical and', ->
        expect(Where(obj,{"$and":[{"a":{"$gt":0}},{"b":{"$lt":6}}]})).to.be(true)
        expect(Where(obj,{"$and":[{"a":{"$gt":2}},{"b":{"$lt":6}}]})).to.be(false)
        expect(Where(obj,{"$and":[{"a":{"$gt":0}},{"b":{"$lt":2}}]})).to.be(false)
        expect(Where(obj,{"$and":[{"a":{"$gt":2}},{"b":{"$lt":2}}]})).to.be(false)
    it 'Where Logical not', ->
        expect(Where(obj,{"f":{"$not":{"$lt":0}}})).to.be(true)
        expect(Where(obj,{"f":{"$not":{"$gt":0}}})).to.be(false)
    it 'Where Logical nor', ->
        expect(Where(obj,{"$nor":[{"f":5},{"b":4}]})).to.be(false)
        expect(Where(obj,{"$nor":[{"f":1},{"b":5}]})).to.be(true)
    it 'Where Element exists', ->
        expect(Where(obj,{"a":{"$exists":true}})).to.be(true)
        expect(Where(obj,{"z":{"$exists":true}})).to.be(false)
        expect(Where(obj,{"z":{"$exists":false}})).to.be(true)
        expect(Where(obj,{"a":{"$exists":false}})).to.be(false)
    it 'Where Element type', ->
        expect(Where(obj,{"a":{"$type":"number"}})).to.be(true)
        expect(Where(obj,{"a":{"$type":"string"}})).to.be(false)
        expect(Where(obj,{"e":{"$type":"string"}})).to.be(true)
        expect(Where(obj,{"a":{"$type":"eric"}})).to.be(false)
        expect(Where(obj,{"d.e":{"$type":-1}})).to.be(false)
    it 'Where Evaluation mod', ->
        expect(Where(obj,{"g":{"$mod":[2,0]}})).to.be(true)
        expect(Where(obj,{"b":{"$mod":[2,0]}})).to.be(true)
        expect(Where(obj,{"f":{"$mod":[3,2]}})).to.be(true)
        expect(Where(obj,{"f":{"$mod":[2,0]}})).to.be(false)
    it 'Where Evaluation regex', ->
        expect(Where(obj, {"h":/\d/})).to.be(true)
        expect(Where(obj,{"c":/\d/})).to.be(true)
        expect(Where(obj,{"e":/\d/})).to.be(true)
        expect(Where(obj,{"i":{ "$regex": 'ello'}})).to.be(true)
        expect(Where(obj,{"i":{ "$regex": 'what'}})).to.be(false)
        expect(Where(obj,{"a":/\d/})).to.be(true)
        expect(Where(obj,{"e":/\b/})).to.be(true)
    it 'Where Array all', ->
        expect(Where(obj,{"h":{"$all": [1,2]}})).to.be(true)
        expect(Where(obj,{"h":{"$all": [4,2]}})).to.be(false)
        expect(Where(obj,{"a":{"$all": [3,2]}})).to.be(false)
    it 'Where Array eleMatch', ->
        expect(Where(obj,{"j": { "$elemMatch": { "book": "xyz", "price": { "$gte": 8 } } }})).to.be(false)
        expect(Where(obj,{"a": { "$elemMatch": { "book": "xyz", "price": { "$gte": 8 } } }})).to.be(false)
        expect(Where(obj,{"j": { "$elemMatch": { "book": "xyz", "price": { "$gte": 6 } } }})).to.be(true)
    it 'Where Array size', ->
        expect(Where(obj,{"h":{"$size": 3}})).to.be(true)
        expect(Where(obj,{"h":{"$size": 6}})).to.be(false)
        expect(Where(obj,{"a":{"$size": 1}})).to.be(false)




