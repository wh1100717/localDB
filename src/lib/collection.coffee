'use strict'

Utils = require('./utils')
Operation = require('./operation')

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
    insert: (rowData, options = {}) ->
        @deserialize()
        @data = Operation.insert @data, rowData, options
        @serialize()

    ###
     *  update collection
    ###
    update: (actions, options = {}) ->
        @deserialize()
        @data = Operation.update @data, actions, options
        @serialize()

    ###
     *  remove data from collection
    ###
    remove: (options = {}) ->
        @deserialize()
        @data = Operation.remove @data, options
        @serialize()

    ###
     * find data from collection
    ###
    find: (options = {}) ->
        @deserialize()
        Operation.find @data, options

    ###
     *  find data and only return one data from collection
    ###
    findOne: (options = {}) ->
        options.limit = 1
        Operation.find @data, options

module.exports = Collection