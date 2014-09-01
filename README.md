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
seajs.use('./dist/localdb.min.js', function(localDB){
    // localDB could be used here.
    ...
})
```

# How To Use

#### Data Structure

A db only contains `_`, only used for finding the collection keys.

A collection is stored as a key, which contains a JSON encoded string, in localStorage. 

```
|- ldb_dbName
    |- ldb_dbName_collectionName1
    |- ldb_dbName_collectionName2
    ...
```

#### Check Browser Compatibility

use `localDB.isSupport()` to check whether the browser support localDB or not.

```javascript
if(!localDB.isSupport()){
    alert("Your browser does not support localDB, pls use modern brower!")
}
```

#### Load Database

use `new localDB(dbName, engineType)` to load a db. you can specify the type of engine with `localStorage` or `sessionStorage`.

```javascript
//localStorage would save the foo db even after browser closed.
//sessionStorage would only save the foo db while the brower stay open.
var db = new localDB("foo", localStorage)
```

#### Delete Database

use `db.drop()` to delete database

```javascript
var db = new localDB("foo", localStorage)
db.drop()
```

#### Delete Collection

use `db.drop(collectionName)` to delete collection

```javascript
var db = new localDB("foo", localStorage)
db.drop("collection1")
```

#### Query Collections

use `db.collections()` to query collections of db.

```javascript
var db = new localDB("foo", localStorage)
db.collections()
```

#### Insert Data

use `db.insert(collectionName, data)` to insert data into specific collection.

```javascript
var db = new localDB("foo", localStorage)
db.insert("collection1", {a:1, b:2, c:3})
```

#### Query data by criteria

use `db.find(collectionName, options)` to find the data in specific collection.

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
var db = new localDB("foo", localStorage)
// to find the data contain key `a`(whose value is greater than 3 and less then 10) and key `b`(whose key equals to 4) and limit is 4.
db.find("collection1",{
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

#### Query only one piece of data by criteria

use `db.findOne(collectionName, options)` to find only one piece of data in specific collection.

options:
*   criteria：  Query Criteria like `where` in MYSQL
*   projection: like `SELECT` in MYSQL 

```
var db = new localDB("foo", localStorage)
db.findOne("collection1",{
    criteria: {
        a: {$gt: 3, $lt: 10},
        b: 4
    }
})
```

#### Update data by criteria

use `db.update(collectionName, options)` to update the data in specific collection.

options:
*   action:     Update action
*   criteria:   Query Criteria like `where` in MYSQL

```javascript
var db = new localDB("foo", localStorage)
// to update the key `b` as 4 and key `c` as 5 of the data limited with criteria
db.update("collection1", {
    action: {
        $set: {b:4, c:5}
    },
    criteria: {
        a: {$gt: 3, $lt: 10}
    }
})
```

#### Delete data by criteria

use `db.remove(collectionName, options)` to delete data in specific collection.

options:
*   criteria:   Query Criteria like `where` in MYSQL

```javascript
var db = new localDB("foo", localStorage)
db.remove("colelction1",{
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


    