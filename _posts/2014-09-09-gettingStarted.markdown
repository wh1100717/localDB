---
layout: gettingStarted
title: "Getting started"
permalink: gettingStarted/
---

<h2 id="installation"> Installation </h2>

<h5 id="byBower"> By Bower </h5>

```bash
$ bower install localdb
```

<h5 id="bySPM"> By SPM </h5>

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

<h2 id="howToUse"> How To Use </h2>

<h5 id="dateStructure"> Data Structure </h5>

A collection is stored as a key, which contains a JSON encoded string, in localStorage. 

```
|- ldb_dbName
    |- ldb_dbName_collectionName1
    |- ldb_dbName_collectionName2
    ...
```

<h5 id="checkBrowserCompatibility"> Check Browser Compatibility </h5>

use `LocalDB.isSupport()` to check whether the browser support LocalDB or not.

```javascript
if(!LocalDB.isSupport()){
    alert("Your browser does not support LocalDB, pls use modern brower!")
}
```

<h5 id="loadDatabase"> Load Database </h5>

use `new LocalDB(dbName, engineType)` to load a db. you can specify the type of engine with `localStorage` or `sessionStorage`.

```javascript
//localStorage would save the foo db even after browser closed.
//sessionStorage would only save the foo db while the brower stay open.
//localStorage by default
var db = new LocalDB("foo", sessionStorage)
```

<h5 id="deleteDatabase"> Delete Database </h5>

use `db.drop()` to delete database

<h5 id="getCollections"> Get Collections </h5>

use `db.collections()` to get collections

<h5 id="getCollection"> Get Collection </h5>

use `db.collection(collectionName)` to get a collection

```
var collection = db.collection("bar")
```

<h5 id="deleteCollection"> Delete Collection </h5>

use `db.drop(collectionName)` or `collection.drop()` to delete collection

```javascript
db.drop("bar")
```

or

```javascript
var collection = db.collection("bar")
collection.drop()
```

<h5 id="insertData"> Insert Data </h5>

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

<h5 id="queryData"> Query Data </h5>

use `collection.find(options)` to find the data in specific collection.

options:

*   where：  Query Criteria like `where` in MYSQL
*   projection: like `SELECT` in MYSQL 
*   limit:  just limit.....

Criteria operations are listed below [Feature]({{ site.baseurl }}feature/):


```javascript
collection.find({
    where: {
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

<h5 id="queryOneRow"> Query one row </h5>

use `collection.findOne(options)`, same as `collection.fine()` except return one item, not a list.


<h5 id="updateDataByCriteria"> Update data by where </h5>

use `collection.update(actions, options)` to update the data in specific collection.

actions:

* $set: set key with value....

options:

* where:   Query Criteria like `where` in MYSQL

```javascript
collection.update({
    $set: {b: 4,c: 5}
}, {
    where: {
        a: {$gt: 3, $lt: 10},
        d: {e: 4}
    }
});
```

<h5 id="deleteDataByCriteria"> Delete data by where </h5>

use `collection.remove(options)` to delete data in specific collection.

options:

*   where:   Query Criteria like `where` in MYSQL

```javascript
collection.remove({
    where: {
        a: {$gt:3 , $lt: 10, $ne: 5}
    }
})
```