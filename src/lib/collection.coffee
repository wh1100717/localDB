'use strict'

Utils = require('./utils')
Projection = require('./projection')
Update = require('./update')
Where = require('./where')

class Collection

    ###
     *  in LocalDB, only use LocalDB to get a collection.
     *  db = new LocalDB('foo')
     *  var collection = db.collection('bar')
    ###
    constructor: (collectionName, db) ->
        @name = "#{db.name}_#{collectionName}"
        @ls = db.ls
        @deserialize()

    ###
     *  get data and tranfer into object from localStorage/sessionStorage
    ###
    deserialize: -> @data = Utils.parse @ls.getItem(@name)

    ###
     *  save data into localStorage/sessionStorage
    ###
    serialize: -> @ls.setItem @name, Utils.stringify(@data)

    ###
     *  delete this collection
    ###
    drop: -> @ls.removeItem @name;true

    ###
     *  insert data into collection
    ###
    insert: (rowData) ->
        @deserialize()
        if Utils.isArray(rowData)
            for d in rowData when Utils.isObject(d)
                d._id = Utils.createObjectId() if not d._id?
                @data.push d
        else if Utils.isObject(rowData)
            rowData._id = Utils.createObjectId() if not rowData._id?
            @data.push rowData
        @serialize()

    ###
     *  update collection
    ###
    update: (actions, options = {}) ->
        @deserialize()
        @data = Update @data, actions, options
        @serialize()

    ###
     *  remove data from collection
    ###
    remove: (options = {}) ->
        where = options.where or {}
        @deserialize()
        @data = (d for d in @data when not Where(d, where))
        @serialize()

    ###
     * find data from collection
    ###
    find: (options = {}) ->
        where = options.where or {}
        projection = options.projection or {}
        limit = options.limit or -1
        @deserialize()
        result = []
        for d in @data when Where(d, where)
            break if limit is 0
            limit = limit - 1
            result.push d
        return Projection.generate(result, projection)

    ###
     *  find data and only return one data from collection
    ###
    findOne: (options = {}) ->
        options.limit = 1
        @find(options)

module.exports = Collection