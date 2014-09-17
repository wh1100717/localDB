'use strict'

Utils = require('./lib/utils')
Collection = require('./lib/collection')

dbPrefix = "ldb_"

class LocalDB

    ###
     *  Constructor
     *  var db = new LocalDB('foo')
     *  var db = new LocalDB('foo', localStorage)
     *  var db = new LocalDB('foo', sessionStorage)
     *
     *  localStorage would save the foo db even after browser closed.
     *  sessionStorage would only save the foo db while the brower stay open.
     *  localStorage by default
    ###
    constructor: (dbName, @ls = localStorage) -> @name = dbPrefix + dbName

    ###
     *  Get Collection Names
     *  db.collections()    //['foo','foo1','foo2','foo3',....]
    ###
    collections: -> (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf("#{@name}_") is 0)

    ###
     *  Get Collection
     *  var collection = db.collection('bar')
    ###
    collection: (collectionName) -> new Collection(collectionName, @)

    ###
     *  Delete Collection: db.drop(collectionName)
     *  Delete DB: db.drop()
    ###
    drop: (collectionName) ->
        collectionName = if collectionName? then "_#{collectionName}" else ""
        keys = (@ls.key(i) for i in [0...@ls.length] when @ls.key(i).indexOf(@name + collectionName) is 0)
        @ls.removeItem(j) for j in keys
        return true

###
 *  Check Browser Compatibility
 *  use LocalDB.isSupport() to check whether the browser support LocalDB or not.
###
LocalDB.isSupport = -> if localStorage? then true else false

module.exports = LocalDB