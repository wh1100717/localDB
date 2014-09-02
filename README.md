localDB
=======

localDB provide simple MongoDB-like API for modern browser with localStorage/sessionStorage.

localDB is designed for web applications, mobile apps or game engines which may store data consistently in browser.

# How does it work?

localDB uses localStorage or sessionStorage to store data in modern browser. The data will stay consistent even after the browser is closed.

localDB does not support IE 6 && 7 currently with userData behavior.

# Installation

```bash
$ bower install localdb
```

TODO: using spm to install localDB

localDB uses seajs (commonJS) as the module loader. Therefore, [seajs](https://github.com/seajs/seajs) should be installed and used first. 

To import localdb module with seajs, the example code is shown below:

```javascript
seajs.use('./dist/localdb.min.js', function(LocalDB){
    // LocalDB could be used here.
    ...
})
```

# How To Use

#### Data Structure

A collection is stored as a key, which contains a JSON encoded string, in localStorage. 

```
|- ldb_dbName
    |- ldb_dbName_collectionName1
    |- ldb_dbName_collectionName2
    ...
```

#### Check Browser Compatibility

use `LocalDB.isSupport()` to check whether the browser support LocalDB or not.

```javascript
if(!LocalDB.isSupport()){
    alert("Your browser does not support LocalDB, pls use modern brower!")
}
```

#### Load Database

use `new LocalDB(dbName, engineType)` to load a db. you can specify the type of engine with `localStorage` or `sessionStorage`.

```javascript
//localStorage would save the foo db even after browser closed.
//sessionStorage would only save the foo db while the brower stay open.
//localStorage by default
var db = new LocalDB("foo", sessionStorage)
```

#### Delete Database

use `db.drop()` to delete database

#### Get Collections

use `db.collections()` to get collections

#### Get Collection

use `db.collection(collectionName)` to get a collection

```
var collection = db.collection("bar")
```

#### Delete Collection

use `db.drop(collectionName)` or `collection.drop()` to delete collection

```javascript
db.drop("bar")
```

or

```javascript
var collection = db.collection("bar")
collection.drop()
```

#### Insert Data

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

#### Query Data

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

#### Query one row

use `collection.findOne(options)`, same as `collection.fine()` except return one item, not a list.


#### Update data by criteria

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

#### Delete data by criteria

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

# Todo List
*   [ ] BSON _ID generator support
*   [ ] [Query Operators](http://docs.mongodb.org/manual/reference/operator/query/)
    *   [ ] [$in](http://docs.mongodb.org/manual/reference/operator/query/in/#op._S_in)
    *   [ ] [$nin](http://docs.mongodb.org/manual/reference/operator/query/nin/#op._S_nin)
*   [ ] [Update Operators](http://docs.mongodb.org/manual/reference/operator/update/)
    *   [ ] [$inc](http://docs.mongodb.org/manual/reference/operator/update/inc/#up._S_inc)
    *   [ ] [$mul](http://docs.mongodb.org/manual/reference/operator/update/mul/#up._S_mul)
    *   [ ] [$rename](http://docs.mongodb.org/manual/reference/operator/update/rename/#up._S_rename)
    *   [ ] [$setOnInsert](http://docs.mongodb.org/manual/reference/operator/update/setOnInsert/#up._S_setOnInsert)
    *   [ ] [$unset](http://docs.mongodb.org/manual/reference/operator/update/unset/#up._S_unset)
    *   [ ] [$min](http://docs.mongodb.org/manual/reference/operator/update/min/#up._S_min)
    *   [ ] [$max](http://docs.mongodb.org/manual/reference/operator/update/max/#up._S_max)
    *   [ ] [$currentDate](http://docs.mongodb.org/manual/reference/operator/update/currentDate/#up._S_currentDate)


    