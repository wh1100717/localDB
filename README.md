localDB
=======

local database using localstorage

###API

```coffee
seajs.use('./src/localdb.js', function(localDB){
    console.log("Current Keys:")
    console.log((ls.key(i) for i in [0...ls.length]))

    console.log("Create new db:")
    abc = new localDB("abc")
    console.log(abc)
 
    console.log("Show Collections:")
    console.log(abc.collections())
 
    console.log("Clear collecionts:")
    console.log(abc.clear())
 
    console.log("Insert data in Collection 1")
    abc.insert("collection1", {a:1,b:2,c:3})
    abc.insert("collection1", {a:2,b:2,c:3})
    abc.insert("collection1", {a:3,b:2,c:3})
    abc.insert("collection1", {a:4,b:2,c:3})
    abc.insert("collection1", {a:5,b:2,c:3})
    abc.insert("collection1", {a:6,b:2,c:3})
    abc.insert("collection1", {a:7,b:2,c:3})
    abc.insert("collection1", {a:8,b:2,c:3})
    abc.insert("collection1", {a:9,b:2,c:3})
    abc.insert("collection1", {a:10,b:2,c:3})
    abc.insert("collection1", {a:11,b:2,c:3})
    abc.insert("collection1", {a:12,b:2,c:3})
    abc.insert("collection2", {a:1,b:2,c:3})

    console.log("Query data by criteria")
    console.log(abc.find("collection1",{a:{$gt:3,$lt:10}}))

    console.log("Query data by criteria and limit")
    console.log(abc.find("collection1",{a:{$gt:3,$lt:10}},4))

    console.log("Update data by criteria and action")
    abc.update("collection1", {$set:{b:4,c:5}} , {a:{$gt:3, $lt:10}}))
    console.log(abc.find("collection1"))

    console.log("Delete data by criteria")
    abc.remove("collection1", {a:{$gt:3,$lt:10}}))
    console.log(abc.find("collection1"))

    console.log("Show Collections:")
    console.log(abc.collections())
```