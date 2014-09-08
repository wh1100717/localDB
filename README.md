#localDB

---

[![spm package][spm-image]][spm-url]
[![Build Status][build-image]][build-url]
[![Coverage Status][coverage-image]][coverage-url]
[![MIT License][license-image]][license-url]

**Still Unstable - Under Developemnt**

localDB provide simple MongoDB-like API for modern browser with localStorage/sessionStorage.

localDB is designed for web applications, mobile apps or game engines which may store data consistently in browser.

##How does it work?

localDB uses localStorage or sessionStorage to store data in modern browser. The data will stay consistent even after the browser is closed.

localDB does not support IE 6 && 7 currently with userData behavior.

##Installation

#####By Bower

```bash
$ bower install localdb
```

#####By SPM

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

##How To Use

#####Data Structure

A collection is stored as a key, which contains a JSON encoded string, in localStorage. 

```
|- ldb_dbName
    |- ldb_dbName_collectionName1
    |- ldb_dbName_collectionName2
    ...
```

#####Check Browser Compatibility

use `LocalDB.isSupport()` to check whether the browser support LocalDB or not.

```javascript
if(!LocalDB.isSupport()){
    alert("Your browser does not support LocalDB, pls use modern brower!")
}
```

#####Load Database

use `new LocalDB(dbName, engineType)` to load a db. you can specify the type of engine with `localStorage` or `sessionStorage`.

```javascript
//localStorage would save the foo db even after browser closed.
//sessionStorage would only save the foo db while the brower stay open.
//localStorage by default
var db = new LocalDB("foo", sessionStorage)
```

#####Delete Database

use `db.drop()` to delete database

#####Get Collections

use `db.collections()` to get collections

#####Get Collection

use `db.collection(collectionName)` to get a collection

```
var collection = db.collection("bar")
```

#####Delete Collection

use `db.drop(collectionName)` or `collection.drop()` to delete collection

```javascript
db.drop("bar")
```

or

```javascript
var collection = db.collection("bar")
collection.drop()
```

#####Insert Data

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

#####Query Data

use `collection.find(options)` to find the data in specific collection.

options:
*   criteria：  Query Criteria like `where` in MYSQL
*   projection: like `SELECT` in MYSQL 
*   limit:  just limit.....

Criteria operations are listed below [Feature](#feature):


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

#####Query one row

use `collection.findOne(options)`, same as `collection.fine()` except return one item, not a list.


#####Update data by criteria

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

#####Delete data by criteria

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

##Feature

###BSON _ID generator support(TODO)

###[Query Operators](http://docs.mongodb.org/manual/reference/operator/query/)

#####Comparison

*   [X] [$gt](http://docs.mongodb.org/manual/reference/operator/query/gt/#op._S_gt)<br>
    Matches values that are greater than the value specified in the query.
*   [X] [$gte](http://docs.mongodb.org/manual/reference/operator/query/gte/#op._S_gte)<br>
    Matches values that are greater than or equal to the value specified in the query.
*   [X] [$lt](http://docs.mongodb.org/manual/reference/operator/query/lt/#op._S_lt)<br>
    Matches values that are less than the value specified in the query.
*   [X] [$lte](http://docs.mongodb.org/manual/reference/operator/query/lte/#op._S_lte)<br>
    Matches values that are less than or equal to the value specified in the query.
*   [X] [$ne](http://docs.mongodb.org/manual/reference/operator/query/ne/#op._S_ne)<br>
    Matches all values that are not equal to the value specified in the query.
*   [X] [$in](http://docs.mongodb.org/manual/reference/operator/query/in/#op._S_in)<br>
    Matches any of the values that exist in an array specified in the query.
*   [X] [$nin](http://docs.mongodb.org/manual/reference/operator/query/nin/#op._S_nin)<br>
    Matches values that do not exist in an array specified to the query.    

#####Logical

*   [X] [$or](http://docs.mongodb.org/manual/reference/operator/query/or/#op._S_or)<br>
    Joins query clauses with a logical **OR** returns all documents that match the conditions of either clause.
*   [X] [$and](http://docs.mongodb.org/manual/reference/operator/query/and/#op._S_and)<br>
    Joins query clauses with a logical **AND** returns all documents that match the conditions of both clauses.
*   [X] [$not](http://docs.mongodb.org/manual/reference/operator/query/not/#op._S_not)<br>
    Inverts the effect of a query expression and returns documents that do not match the query expression.
*   [X] [$nor](http://docs.mongodb.org/manual/reference/operator/query/nor/#op._S_nor)<br>
    Joins query clauses with a logical **NOR** returns all documents that fail to match both clauses.

#####Element

*   [X] [$exists](http://docs.mongodb.org/manual/reference/operator/query/exists/#op._S_exists)<br>
    Matches documents that have the specified field.
*   [X] [$type](http://docs.mongodb.org/manual/reference/operator/query/type/#op._S_type)<br>
    Selects documents if a field is of the specified type.

>Note: <br>
>It is different from the **$type** API in MongoDB.<br>
>It is really easy to determine the type of element in javascript.<br>
>Support type input string: `string` | `object` | `function` | `array` | `number`

#####Evaluation

*   [X] [$mod](http://docs.mongodb.org/manual/reference/operator/query/mod/#op._S_mod)<br>
    Performs a modulo operation on the value of a field and selects documents with a specified result.
*   [X] [$regex](http://docs.mongodb.org/manual/reference/operator/query/regex/#op._S_regex)<br>
    Selects documents where values match a specified regular expression.
*   [ ] [$text](http://docs.mongodb.org/manual/reference/operator/query/text/#op._S_text)<br>
    Performs text search.
*   [ ] [$where](http://docs.mongodb.org/manual/reference/operator/query/where/#op._S_where)<br>
    Matches documents that satisfy a JavaScript expression.

#####Array

*   [X] [$all](http://docs.mongodb.org/manual/reference/operator/query/all/#op._S_all)<br>
    Matches arrays that contain all elements specified in the query.
*   [X] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/query/elemMatch/#op._S_elemMatch)<br>
    Selects documents if element in the array field matches all the specified **$elemMatch** condition.
*   [X] [$size](http://docs.mongodb.org/manual/reference/operator/query/size/#op._S_size)<br>
    Selects documents if the array field is a specified size.

#####Projection Operators

*   [X] [$](http://docs.mongodb.org/manual/reference/operator/projection/positional/#proj._S_)<br>
    Projects the first element in an array that matches the query condition.
*   [X] [$elemMatch](http://docs.mongodb.org/manual/reference/operator/projection/elemMatch/#proj._S_elemMatch)<br>
    Projects only the first element from an array that matches the specified **$elemMatch** condition.
*   [ ] [$meta](http://docs.mongodb.org/manual/reference/operator/projection/meta/#proj._S_meta)<br>
    Projects the document’s score assigned during **$text** operation.
*   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/projection/slice/#proj._S_slice)<br>
    Limits the number of elements projected from an array. Supports skip and limit slices.

###[Update Operators](http://docs.mongodb.org/manual/reference/operator/update/)

#####Fields

*   [X] [$inc](http://docs.mongodb.org/manual/reference/operator/update/inc/#up._S_inc)<br>
    Increments the value of the field by the specified amount.
*   [X] [$mul](http://docs.mongodb.org/manual/reference/operator/update/mul/#up._S_mul)<br>
    Multiplies the value of the field by the specified amount.
*   [X] [$rename](http://docs.mongodb.org/manual/reference/operator/update/rename/#up._S_rename)<br>
    Renames a field.
*   [ ] [$setOnInsert](http://docs.mongodb.org/manual/reference/operator/update/setOnInsert/#up._S_setOnInsert)<br>
    Sets the value of a field upon document creation during an upsert. Has no effect on update operations that modify existing documents.
*   [X] [$set](http://docs.mongodb.org/manual/reference/operator/update/set/#up._S_set)<br>
    Sets the value of a field in a document.
*   [X] [$unset](http://docs.mongodb.org/manual/reference/operator/update/unset/#up._S_unset)<br>
    Removes the specified field from a document.
*   [ ] [$min](http://docs.mongodb.org/manual/reference/operator/update/min/#up._S_min)<br>
    Only updates the field if the specified value is less than the existing field value.
*   [ ] [$max](http://docs.mongodb.org/manual/reference/operator/update/max/#up._S_max)<br>
    Only updates the field if the specified value is greater than the existing field value.
*   [ ] [$currentDate](http://docs.mongodb.org/manual/reference/operator/update/currentDate/#up._S_currentDate)<br>
    Sets the value of a field to current date, either as a Date or a Timestamp.

#####Array
*   [ ] [$](http://docs.mongodb.org/manual/reference/operator/update/positional/#up._S_)<br>
    Acts as a placeholder to update the first element that matches the query condition in an update.
*   [ ] [$addToSet](http://docs.mongodb.org/manual/reference/operator/update/addToSet/#up._S_addToSet)<br>
    Adds elements to an array only if they do not already exist in the set.
*   [ ] [$pop](http://docs.mongodb.org/manual/reference/operator/update/pop/#up._S_pop)<br>
    Removes the first or last item of an array.
*   [ ] [$pullAll](http://docs.mongodb.org/manual/reference/operator/update/pullAll/#up._S_pullAll)<br>
    Removes all matching values from an array.
*   [ ] [$pull](http://docs.mongodb.org/manual/reference/operator/update/pull/#up._S_pull)<br>
    Removes all array elements that match a specified query.
*   [ ] [$pushAll](http://docs.mongodb.org/manual/reference/operator/update/pushAll/#up._S_pushAll)<br>
    Deprecated. Adds several items to an array.
*   [ ] [$push](http://docs.mongodb.org/manual/reference/operator/update/push/#up._S_push)<br>
    Adds an item to an array.

#####Modifiers
*   [ ] [$each](http://docs.mongodb.org/manual/reference/operator/update/each/#up._S_each)<br>
    Modifies the **$push** and **$addToSet** operators to append multiple items for array updates.
*   [ ] [$slice](http://docs.mongodb.org/manual/reference/operator/update/slice/#up._S_slice)<br>
    Modifies the **$push** operator to limit the size of updated arrays.
*   [ ] [$sort](http://docs.mongodb.org/manual/reference/operator/update/sort/#up._S_sort)<br>
    Modifies the **$push** operator to reorder documents stored in an array.
*   [ ] [$position](http://docs.mongodb.org/manual/reference/operator/update/position/#up._S_position)<br>
    Modifies the **$push** operator to specify the position in the array to add elements.

#####Bitwise

*   [ ] [$bit](http://docs.mongodb.org/manual/reference/operator/update/bit/#up._S_bit)<br>
    Performs bitwise **AND**, **OR**, and **XOR** updates of integer values.

#####Isolation
       
*   [ ] [$isolated](http://docs.mongodb.org/manual/reference/operator/update/isolated/#up._S_isolated)<br>
    Modifies behavior of multi-updates to increase the isolation of the operation.

[spm-image]: http://spmjs.io/badge/localdb
[spm-url]: http://spmjs.io/package/localdb
[build-image]: https://api.travis-ci.org/wh1100717/localDB.svg?branch=master
[build-url]: https://travis-ci.org/wh1100717/localDB
[coverage-image]: https://img.shields.io/coveralls/wh1100717/localDB.svg
[coverage-url]: https://coveralls.io/r/wh1100717/localDB?branch=master
[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat
[license-url]: LICENSE
