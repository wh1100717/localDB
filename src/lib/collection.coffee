'use strict'

Utils = require('./utils')
Criteria = require('./criteria')
Projection = require('./projection')
Update = require('./update')

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
    drop: -> @ls.removeItem @name

    ###
     *  insert data into collection
    ###
    insert: (rowData) ->
        @deserialize()
        @data.push rowData
        @serialize()

    ###
     *  update collection
    ###
    update: (actions, options = {}) ->
        criteria = options.criteria or {}
        @deserialize()
        @data = Update @data, actions, criteria
        @serialize()

    ###
     *  remove data from collection
    ###
    remove: (options = {}) ->
        criteria = options.criteria or {}
        @deserialize()
        @data = (d for d in @data when not Criteria.check(d, criteria))
        @serialize()

    ###
     * find data from collection
    ###
    find: (options = {}) ->
        criteria = options.criteria or {}
        projection = options.projection or {}
        limit = options.limit or -1
        @deserialize()
        result = []
        for d in @data when Criteria.check(d, criteria)
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