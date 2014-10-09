# API Reference

---

## LocalDB

```javascript
/*
 * 查看浏览器对localDB的支持情况
 * @return(OBJECT): 返回一个对象，对象中包含浏览器对localStorage、sessionStorage、indexedDB的支持情况
*/
result = LocalDB.support()
//result: {localStorage: true, sessionStorage, true, indexedDB: false}

/* 创建/获取 名为dbName的db: new LocalDB(dbName, options)
 *  @para dbName(STRING): db名
 *  @para options(OBJECT): 可选配置项
    *   engine: 选用的存储引擎，可选localStorage/sessionStorage
 *  @return(OBJECT LocalDB): 返回LocalDB构造的对象，包含了具体db的所有操作。
*/
db = new LocalDB('foo', {
    engine: localStorage
})

//获取该db的options配置信息
options = db.options()

/* 获取该db的所有collection
 * @return(ARRAY): 返回包含该db所有collection名的数组
*/
collections = db.collections()  // ['bar1','bar2','bar3']

/* 创建/获取 名为collectionName的collection: db.collection(collectionName, options)
 *  @para collectionName(STRING): collection名
 *  @para options(OBJECT): 可选配置项(预留)
 *  @return(OBJECT Collection): 返回Collection构造的对象，包含了具体collection的所有操作。
*/
collection = db.collection('bar')

/* 删除db/collection
 *  删除数据库： db.drop()
 *  删除collection: db.drop('bar')
 *  @para collectionName(STRING): 需要删除的collection名
 *  @return(BOOL): 返回是否删除成功
*/
db.drop('bar') // true / false
db.drop()      // true / false
```

## Collection

```javascript
/* 删除collection
 *  @return(BOOL): 返回是否删除成功
*/
collection.drop()

/* 插入对象/数组对象: collection.insert(rowData)
 *  @para rowData(OBJECT/ARRAY): 要插入的对象，如果一次想插入多条数据，可以直接传对象数组，如果数组中有非对象item，则该item忽略。
 *  @return(BOOL): 返回是否插入成功
*/
collection.insert({
    item: "ABC1",
    details: {
        model: "14Q3",
        manufacturer: "XYZ Company"
    },
    stock: [ { size: "S", qty: 25 }, { size: "M", qty: 50 } ],
    category: "clothing"
})
/* 插入的数据如下：
{ "_id" : ObjectId("53d98f133bb604791249ca99"), "item" : "ABC1", "details" : { "model" : "14Q3", "manufacturer" : "XYZ Company" }, "stock" : [ { "size" : "S", "qty" : 25 }, { "size" : "M", "qty" : 50 } ], "category" : "clothing" }
*/
collection.insert([
    {
        item: "ABC2",
        details: { model: "14Q3", manufacturer: "M1 Corporation" },
        stock: [ { size: "M", qty: 50 } ],
        category: "clothing"
    },
    {
        item: "MNO2",
        details: { model: "14Q3", manufacturer: "ABC Company" },
        stock: [ { size: "S", qty: 5 }, { size: "M", qty: 5 }, { size: "L", qty: 1 } ],
        category: "clothing",
        number: 1
    },
    {
        item: "IJK2",
        details: { model: "14Q2", manufacturer: "M5 Corporation" },
        stock: [ { size: "S", qty: 5 }, { size: "L", qty: 1 } ],
        category: "houseware"
    }
])

/* 更新指定数据: collection.update(actions, options)
 *  @para actions(OBJECT): 指定需要执行的更新操作
 *  @para options(OBJECT): 可选项
    *   @para where(OBJECT): 更新条件
    *   @para multi(BOOL): 默认情况下update更新全部数据，如果需要将只更新匹配上的第一条数据，则将multi设置为false。
    *   @para upsert(BOOL): 如果没有满足where条件的，则update什么都不做，upsert如果为true，则在没有满足where条件的情况下，会插入一条数据。
*/
collection.update({
    $set: {
        category: "apparel",
        details: { model: "14Q3", manufacturer: "XYZ Company" }
    },
    $inc: {
        number: 1
    }
}, {
    where: {item: "MNO2"},
    multi: true,
    upsert: false
})

/* 删除指定数据: collection.remove(options)
 *  @para options(OBJECT): 可选项
    *   @para where(OBJECT): 删除条件
    *   @para multi(BOOL):  默认为true,如果设置为false，则只删除遇到的第一条数据
*/
collection.remove({
    where: {item: "MNO2"},
    multi: false
})

/* 查询数据: collection.find(options)
*   @para options(OBJECT): 可选项
    *   @para where(OBJECT): 查询条件
    *   @para projection(OBJECT): 构造查询结果包含的项
    *   @para limit(NUMBER): 返回数据的数量
*/
collection.find({
    where: {
        type: 'food',
        $or: [ { qty: { $gt: 100 } }, { price: { $lt: 9.95 } } ]
   },
   limit: 10,
   sort: {food: 1, qty: -1}
})
```

