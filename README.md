# localDB

---

[![spm package][spm-image]][spm-url]
[![MIT License][license-image]][license-url]
[![Build Status][build-image]][build-url]
[![Coverage Status][coverage-image]][coverage-url]

localDB provide simple MongoDB-like API for modern browser with localStorage/sessionStorage.

localDB is designed for web applications, mobile apps or game engines which may store data consistently in browser.

## How does it work?

localDB uses localStorage or sessionStorage to store data in modern browser. The data will stay consistent even after the browser is closed.

localDB does not support IE 6 && 7 currently with userData behavior.

## Installation

##### By Bower

```bash
$ bower install localdb
```

##### By SPM

```bash
$ spm install localdb
```

localDB uses seajs (commonJS) as the module loader.
Therefore, [seajs](https://github.com/seajs/seajs) should be installed and used first. 

To import localdb module with seajs, the example code is shown below:

```javascript
seajs.use('./dist/localdb/0.0.1/src/localdb.js', function(LocalDB){
    // LocalDB could be used here.
    ...
})
```

## How To Use

##### Data Structure

A collection is stored as a key, which contains a JSON encoded string, in localStorage. 

```
|- ldb_dbName
    |- ldb_dbName_collectionName1
    |- ldb_dbName_collectionName2
    ...
```

##### Check Browser Compatibility

use `LocalDB.isSupport()` to check whether the browser support LocalDB or not.

```javascript
if(!LocalDB.isSupport()){
    alert("Your browser does not support LocalDB, pls use modern brower!")
}
```

##### Load Database

use `new LocalDB(dbName, engineType)` to load a db. you can specify the type of engine with `localStorage` or `sessionStorage`.

```javascript
//localStorage would save the foo db even after browser closed.
//sessionStorage would only save the foo db while the brower stay open.
//localStorage by default
var db = new LocalDB("foo", sessionStorage)
```

##### Delete Database

use `db.drop()` to delete database

##### Get Collections

use `db.collections()` to get collections

##### Get Collection

use `db.collection(collectionName)` to get a collection

```
var collection = db.collection("bar")
```

##### Delete Collection

use `db.drop(collectionName)` or `collection.drop()` to delete collection

```javascript
db.drop("bar")
```

or

```javascript
var collection = db.collection("bar")
collection.drop()
```

##### Insert Data

use `collection.insert(data)` to insert data into specific collection.

```
collection.insert({
    a: 1,
    b: 2,
    c: 3,
    d: {
        e: 4,
        f: 5
    }
})
```

##### Query Data

use `collection.find(options)` to find the data in specific collection.

options:
*   criteria：  Query Criteria like `where` in MYSQL
*   projection: like `SELECT` in MYSQL 
*   limit:  just limit.....

There are six criteria operations currently:

*   $gt: greater than (>)
*   $gte: greater than or equal to (>=)
*   $lt: less than (<)
*   $lte: less than or equal to (<=)
*   $ne: not equal to (!=)

```javascript
collection.find({
    criteria: {
        a: {$gt: 3, $lt: 10},
        b: 4
    },
    projection: {
        a: 1,
        b: 1,
        c: 0
    },
    limit: 4
})
```

##### Query one row

use `collection.findOne(options)`, same as `collection.fine()` except return one item, not a list.


##### Update data by criteria

use `collection.update(actions, options)` to update the data in specific collection.

actions:
*   $set: set key with value....

options:
*   criteria:   Query Criteria like `where` in MYSQL

```javascript
collection.update({
    $set: {b: 4,c: 5}
}, {
    criteria: {
        a: {$gt: 3, $lt: 10},
        d: {e: 4}
    }
});
```

##### Delete data by criteria

use `collection.remove(options)` to delete data in specific collection.

options:
*   criteria:   Query Criteria like `where` in MYSQL

```javascript
collection.remove({
    criteira: {
        a: {$gt:3 , $lt: 10, $ne: 5}
    }
})
```

## Todo List
*   [ ] BSON _ID generator support
*   [ ] [Query Operators](http://docs.mongodb.org/manual/reference/operator/query/)
    *   Comparison
        *   [X] [$gt](http://docs.mongodb.org/manual/reference/operator/query/gt/#op._S_gt)
        *   [X] [$gte](http://docs.mongodb.org/manual/reference/operator/query/gte/#op._S_gte)
        *   [X] [$lt](http://docs.mongodb.org/manual/reference/operator/query/lt/#op._S_lt)
        *   [X] [$lte](http://docs.mongodb.org/manual/reference/operator/query/lte/#op._S_lte)
        *   [X] [$ne](http://docs.mongodb.org/manual/reference/operator/query/ne/#op._S_ne)
        *   [X] [$in](http://docs.mongodb.org/manual/reference/operator/query/in/#op._S_in)
        *   [X] [$nin](http://docs.mongodb.org/manual/reference/operator/query/nin/#op._S_nin)
    *   Logical
        *   [X] [$or](http://docs.mongodb.org/manual/reference/operator/query/or/#op._S_or)
        *   [X] [$and](http://docs.mongodb.org/manual/reference/operator/query/and/#op._S_and)
        *   [X] [$not](http://docs.mongodb.org/manual/reference/operator/query/not/#op._S_not)
        *   [X] [$nor](http://docs.mongodb.org/manual/reference/operator/query/nor/#op._S_nor)
    *   Element
        *   [X] [$exits](http://docs.mongodb.org/manual/reference/operator/query/exists/#op._S_exists)
        *   [X] [$type](http://docs.mongodb.org/manual/reference/operator/query/type/#op._S_type)
            Note: It is different from the $type API in MongoDB. It is really easy to determine the type of element in javascript. and u can just use {$type: type}(support type input string: `string` | `object` | `function` | `array` | `number`)
    *   Evaluation
        *   [ ] [$mod](http://docs.mongodb.org/manual/reference/operator/query/mod/#op._S_mod)
        *   [ ] [$regex](http://docs.mongodb.org/manual/reference/operator/query/regex/#op._S_regex)
        *   [ ] [$text](http://docs.mongodb.org/manual/reference/operator/query/text/#op._S_text)
        *   [ ] [$where](http://docs.mongodb.org/manual/reference/operator/query/where/#op._S_where)
    *   Array
        *   [ ] [$all](http://docs.mongodb.org/manual/reference/operator/query/all/#op._S_all)
        *   [ ] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/query/elemMatch/#op._S_elemMatch)
        *   [ ] [$size](http://docs.mongodb.org/manual/reference/operator/query/size/#op._S_size)
    *   Projection Operators
        *   [ ] [$](http://docs.mongodb.org/manual/reference/operator/projection/positional/#proj._S_)
        *   [ ] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/projection/elemMatch/#proj._S_elemMatch)
        *   [ ] [$meta](http://docs.mongodb.org/manual/reference/operator/projection/meta/#proj._S_meta)
        *   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/projection/slice/#proj._S_slice)

*   [ ] [Update Operators](http://docs.mongodb.org/manual/reference/operator/update/)
    *   Fields
        *   [ ] [$inc](http://docs.mongodb.org/manual/reference/operator/update/inc/#up._S_inc)
        *   [ ] [$mul](http://docs.mongodb.org/manual/reference/operator/update/mul/#up._S_mul)
        *   [ ] [$rename](http://docs.mongodb.org/manual/reference/operator/update/rename/#up._S_rename)
        *   [ ] [$setOnInsert](http://docs.mongodb.org/manual/reference/operator/update/setOnInsert/#up._S_setOnInsert)
        *   [X] [$set](http://docs.mongodb.org/manual/reference/operator/update/set/#up._S_set)
        *   [ ] [$unset](http://docs.mongodb.org/manual/reference/operator/update/unset/#up._S_unset)
        *   [ ] [$min](http://docs.mongodb.org/manual/reference/operator/update/min/#up._S_min)
        *   [ ] [$max](http://docs.mongodb.org/manual/reference/operator/update/max/#up._S_max)
        *   [ ] [$currentDate](http://docs.mongodb.org/manual/reference/operator/update/currentDate/#up._S_currentDate)
    *   Array
        *   [ ] [$](http://docs.mongodb.org/manual/reference/operator/update/positional/#up._S_)
        *   [ ] [$addToSet](http://docs.mongodb.org/manual/reference/operator/update/addToSet/#up._S_addToSet)
        *   [ ] [$pop](http://docs.mongodb.org/manual/reference/operator/update/pop/#up._S_pop)
        *   [ ] [$pullAll](http://docs.mongodb.org/manual/reference/operator/update/pullAll/#up._S_pullAll)
        *   [ ] [$pull](http://docs.mongodb.org/manual/reference/operator/update/pull/#up._S_pull)
        *   [ ] [$pushAll](http://docs.mongodb.org/manual/reference/operator/update/pushAll/#up._S_pushAll)
        *   [ ] [$push](http://docs.mongodb.org/manual/reference/operator/update/push/#up._S_push)
    *   Modifiers
        *   [ ] [$each](http://docs.mongodb.org/manual/reference/operator/update/each/#up._S_each)
        *   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/update/slice/#up._S_slice)
        *   [ ] [$sort](http://docs.mongodb.org/manual/reference/operator/update/sort/#up._S_sort)
        *   [ ] [$position](http://docs.mongodb.org/manual/reference/operator/update/position/#up._S_position)
    *   Bitwise
        *   [ ] [$bit](http://docs.mongodb.org/manual/reference/operator/update/bit/#up._S_bit)
    *   Isolation
        *   [ ] [$isolated](http://docs.mongodb.org/manual/reference/operator/update/isolated/#up._S_isolated)

[spm-image]: http://spmjs.io/badge/localdb
[spm-url]: http://spmjs.io/package/localdb
[build-image]: https://api.travis-ci.org/wh1100717/localDB.svg?branch=master
[build-url]: https://travis-ci.org/wh1100717/localDB
[coverage-image]: https://img.shields.io/coveralls/wh1100717/localDB.svg
[coverage-url]: https://coveralls.io/r/wh1100717/localDB?branch=master
[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat
[license-url]: LICENSE
