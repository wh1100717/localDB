localDB
=======

localDB provide simple MongoDB-like API for modern browser with localStorage/sessionStorage.

localDB is designed for web applications, mobile apps or game engines which may store data consistently in browser.

# How does it work?

---

localDB uses localStorage or sessionStorage to store data in modern browser. The data will stay consistent even after the browser is closed.

localDB does not support IE 6 && 7 currently with userData behavior.

# Installation

---

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

---

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

use `db.collections()` to query collections under db.

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

use `db.find(collectionName, criteria, limit)` to find the data in specific collection.

There are six criteria operations currently:

*   $gt: greater than (>)
*   $gte: greater than or equal to (>=)
*   $lt: less than (<)
*   $lte: less than or equal to (<=)
*   $ne: not equal to (!=)
*   $eq: equal to (==)

```javascript
var db = new localDB("foo", localStorage)
// to find the data contain key `a`(whose value is greater than 3 and less then 10) and key `b`(whose key equals to 4) and limit is 4.
db.find("collection1", {
    a: {$gt: 3, $lt: 10},
    b: {$eq: 4}
}, 4)
```

#### Update data by criteria

use `db.update(collectionName, action, criteria)` to update the data in specific collection.

```javascript
var db = new localDB("foo", localStorage)
// to update the key `b` as 4 and key `c` as 5 of the data limited with criteria
db.update("collection1", {
    $set: {b:4, c:5}
},{
    a: {$gt: 3, $lt: 10}
})
```

#### Delete data by criteria

use `db.remove(collectionName, criteria)` to delete data in specific collection.

```javascript
var db = new localDB("foo", localStorage)
db.delete("collection1", {
    a: {$gt:3 , $lt: 10, $ne: 5}
})
```



