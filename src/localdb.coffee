define (require, exports, module) ->
    'use strict'

    Utils = require('lib/utils')
    Collection = require('lib/collection')
    Engine = require('lib/engine')
    Support = require('lib/support')

    dbPrefix = "ldb_"

    class LocalDB

        ###
         *  Constructor
         *  var db = new LocalDB('foo')
         *  var db = new LocaoDB('foo', {
                session: true,
                encrypt: true,
                proxy: "http://www.foo.com/getProxy.html"
            })
         *
         *  Engine will decide to choose the best waty to handle the data automatically.
         *  when session is true, the data will be alive while browser stay open. e.g. sessionStorage
         *  when session is false, the data will be alive even after browser is closed. e.g. localStorage
         *  true by default
         *  The data will be stored encrypted if the encrpyt options is true, true by default.
        ###
        constructor: (dbName, options = {}) ->
            throw new Error("dbName should be specified.") if dbName is undefined
            @name = dbPrefix + dbName
            @session = if options.session? then options.session else true
            @encrypt = if options.encrypt? then options.encrypt else true
            @proxy = if options.proxy? then options.proxy else null
            @engine = new Engine(@session, @encrypt, @name, @proxy)

        # get options
        options: -> {
            name: @name.substr(dbPrefix.length)
            session: @session
            encrypt: @encrypt
            proxy: @proxy
        }

        # ###
        #  *  Get Collection Names
        #  *  db.collections()    //['foo','foo1','foo2','foo3',....]
        # ###
        # collections: -> (@ls.key(i).substr("#{@name}_".length) for i in [0...@ls.size()] when @ls.key(i).indexOf("#{@name}_") is 0)

        ###
         *  Get Collection
         *  var collection = db.collection('bar')
        ###
        collection: (collectionName) -> new Collection(collectionName, @engine)

        ###
         *  Delete Collection: db.drop(collectionName)
         *  Delete DB: db.drop()
        ###
        # drop: (collectionName, callback) ->
        #     collectionName = if collectionName? then "_#{collectionName}" else ""
        #     keys = (@ls.key(i) for i in [0...@ls.size()] when @ls.key(i).indexOf(@name + collectionName) is 0)
        #     @ls.removeItem(j) for j in keys
        #     return true

    ###
     *  Check Browser Feature Compatibility
    ###
    LocalDB.support = Support

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