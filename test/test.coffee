define (require, exports) ->
    LocalDB = require('../src/localdb.js')

    console.log "localDB is supported by your browser!" if LocalDB.isSupport()

    ###
     *  Generate database
     *  you can use sessionStorage aslo
     *  `db = LocalDB("db_foo", sessionStorage)`
    ###
    db = new LocalDB("db_foo")

    ###
     *  Get collections of db_foo
    ###
    console.log db.collections()

    ###
     *  Drop this db
    ###
    db.drop()

    ###
     *  Drop collection
    ###
    db.drop("collection_bar")

    ###
     *  Get Collection
    ###
    collection = db.collection("collection_bar")

    console.log collection

    ###
     *  Drop Collection
    ###
    collection.drop()

    console.log collection

    ###
     * Insert Collection 
    ###
    collection.insert({a:1,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:2,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:3,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:4,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:5,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:6,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:7,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:8,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:10,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:11,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:12,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:13,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:14,b:2,c:3,d:{e:4,f:5}})
    collection.insert({a:15,b:2,c:3,d:{e:4,f:5}})

    console.log collection.data

    ###
     *  update Collection
    ###
    collection.update {
        $set: {b:4, c:5}
    }, {
        criteria: {
            a: {$gt: 3, $lt: 10},
            d: {
                e: 4
            }
        }
    }

    console.log collection.data

    ###
     *  remove data from Collection
    ###
    collection.remove {
        criteria: {
            a: {$gt:3, $lt: 10}
        }
    }

    console.log collection.data

    ###
     *  find
    ###
    data = collection.find {
        criteria: {
            a:{$lt:3},
            b:2
        },
        projection: {
            a: 1,
            b: 1,
            c: 0
        },
        limit: 4
    }
    console.log "Find()"
    console.log data

    ###
     *  findOne
    ###
    data = collection.findOne {
        criteria: {
            a:{$lt:3}
        }
    }
    console.log data
