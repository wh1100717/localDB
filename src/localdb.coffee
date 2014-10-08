'use strict'

Utils = require('./lib/utils')
Collection = require('./lib/collection')

dbPrefix = "ldb_"

class LocalDB

    ###
     *  Constructor
     *  var db = new LocalDB('foo')
     *  var db = new LocalDB('foo', {engine: localStorage})
     *  var db = new LocalDB('foo', {engine: sessionStorage})
     *
     *  localStorage would save the foo db even after browser closed.
     *  sessionStorage would only save the foo db while the brower stay open.
     *  localStorage by default
    ###
    constructor: (dbName, options = {}) ->
        #TODO 如果以后增加一些新的配置项，比如说size，则需要将db带着options内容存储起来，执行构造函数的时候也需要先通过@name和@ls来查看该db是否已经存在。
        @name = dbPrefix + dbName
        @ls = options.engine or localStorage

    # get options
    options: -> {
        name: @name.substr(dbPrefix.length)
        engine: @ls
    }

    ###
     *  Get Collection Names
     *  db.collections()    //['foo','foo1','foo2','foo3',....]
    ###
    collections: -> (@ls.key(i).substr("#{@name}_".length) for i in [0...@ls.length] when @ls.key(i).indexOf("#{@name}_") is 0)

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
     *  Get Timestamp
     *  Convert ObjectId to timestamp
    ###
    timestamp: (objectId) -> Utils.timestamp(objectId)

###
 *  Check Browser Compatibility
 *  use LocalDB.isSupport() to check whether the browser support LocalDB or not.
###
LocalDB.support = -> {
    localStorage: if localStorage? then true else false
    sessionStorage: if sessionStorage? then true else false
    indexedDB: if indexedDB? then true else false
}

module.exports = LocalDB