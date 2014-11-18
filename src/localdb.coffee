define (require, exports, module) ->
    "use strict"

    Support = require("lib/support")
    Utils = require("core/utils")
    Collection = require("core/collection")
    Engine = require("core/engine")
    Server = require("core/server")

    dbPrefix = "ldb_"
    version = ""

    class LocalDB

        ###
         *  Constructor
         *  var db = new LocalDB("foo")
         *  var db = new LocaoDB("foo", {
                expire: "window",
                encrypt: true,
                proxy: "http://www.foo.com/getProxy.html"
            })
         *
         *  Engine will decide to choose the best way to handle data automatically.
            *   when expire is set as "window", the data wil be alive while the window page stay open
            *   when expire is set as "none", the data will be always stored even after the browser is closed.
            *   "window" by default
            *   TODO: "browser", means the data will be alive and shared between the same origin page and disappear when the brower close.
            *   TODO: Date(), means the data will be alive until Date()
         *  The data will be stored encrypted if the encrypt options is true, true by default.
        ###
        constructor: (dbName, options = {}) ->
            throw new Error("dbName should be specified.") if not dbName?
            @name = dbPrefix + dbName
            @expire = if options.expire? then options.expire else "window"
            @encrypt = if options.encrypt? then options.encrypt else true
            @proxy = if options.proxy? then options.proxy else null
            @insert_guarantee = if options.guarantee then options.guarantee else false
            @engine = new Engine {
                expire: @expire
                encrypt: @encrypt
                name: @name
                proxy: @proxy
                insert_guarantee: @insert_guarantee
            }

        # get options
        options: -> {
            name: @name.substr(dbPrefix.length)
            expire: @expire
            encrypt: @encrypt
            proxy: @proxy
        }

        # ###
        #  *  Get Collection Names
        #  *  db.collections()    //["foo","foo1","foo2","foo3",....]
        # ###
        # collections: -> (@ls.key(i).substr("#{@name}_".length) for i in [0...@ls.size()] when @ls.key(i).indexOf("#{@name}_") is 0)

        ###
         *  Get Collection
         *  var collection = db.collection("bar")
        ###
        collection: (collectionName) ->
            throw new Error("collectionName should be specified.") if not collectionName?
            new Collection(collectionName, @engine)

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
    LocalDB.getSupport = -> Support

    ###
     *  Version
    ###
    LocalDB.getVersion = -> version

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

    ###
     *  Proxy Server Init
     *  LocalDB.init({
            allow: ["*.baidu.com", "pt.aliexpress.com"]
            deny: ["map.baidu.com"]
        })
    ###
    LocalDB.init = (config) -> (new Server(config)).init()


    module.exports = LocalDB