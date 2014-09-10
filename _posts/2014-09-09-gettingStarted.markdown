---
layout: gettingStarted
title: "Getting started"
permalink: gettingStarted/
---

<h2 id="installation"> Installation </h2>

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

Criteria operations are listed below [Feature]({{ site.baseurl }}feature/):


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

* $set: set key with value....

options:

* criteria:   Query Criteria like `where` in MYSQL

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