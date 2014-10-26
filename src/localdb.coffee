define (require, exports, module) ->
    'use strict'

    Utils = require('lib/utils')
    Collection = require('lib/collection')
    Engine = require('lib/engine')

    dbPrefix = "ldb_"

    class LocalDB

        ###
         *  Constructor
         *  var db = new LocalDB('foo')
         *  var db = new LocalDB('foo', {type: 1})
         *  var db = new LocalDB('foo', {type: 2})
         *
         *  Engine will decide to choose the best waty to handle the data automatically.
         *  when type is 1, the data will be alive while browser stay open. e.g. sessionStorage
         *  when type is 2, the data will be alive even after browser is closed. e.g. localStorage
         *  1 by default
        ###
        constructor: (dbName, options = {}) ->
            #TODO 如果以后增加一些新的配置项，比如说size，则需要将db带着options内容存储起来，执行构造函数的时候也需要先通过@name和@ls来查看该db是否已经存在。
            throw new Error("dbName should be specified.") if dbName is undefined
            @name = dbPrefix + dbName
            @ls = new Engine(options.type or 1)

        # get options
        options: -> {
            name: @name.substr(dbPrefix.length)
            type: @ls.type
        }

        ###
         *  Get Collection Names
         *  db.collections()    //['foo','foo1','foo2','foo3',....]
        ###
        collections: -> (@ls.key(i).substr("#{@name}_".length) for i in [0...@ls.size()] when @ls.key(i).indexOf("#{@name}_") is 0)

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
            keys = (@ls.key(i) for i in [0...@ls.size()] when @ls.key(i).indexOf(@name + collectionName) is 0)
            @ls.removeItem(j) for j in keys
            return true

    ###
     *  Check Browser Compatibility
     *  use LocalDB.isSupport() to check whether the browser support LocalDB or not.
    ###
    LocalDB.support = -> {
        localStorage: if localStorage? then true else false
        sessionStorage: if sessionStorage? then true else false
        indexedDB: false
    }
    ###
     *  Get Timestamp
     *  Convert ObjectId to timestamp
    ###
    LocalDB.getTimestamp = (objectId) -> Utils.getTimestamp(objectId)

    ###
     *  Get Time
     *  Convert ObjectId to time
    ###
    LocalDB.getTime = (objectId) -> Utils.getTime(objectId)

    # window.LocalDB = LocalDB if not seajs?

    module.exports = LocalDB