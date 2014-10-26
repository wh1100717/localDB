define (require, exports, module) ->
    'use strict'

    Utils = require('lib/utils')
    Operation = require('lib/operation')

    class Collection

        ###
         *  in LocalDB, only use LocalDB to get a collection.
         *  db = new LocalDB('foo')
         *  var collection = db.collection('bar')
        ###
        constructor: (collectionName, db) ->
            throw new Error("collectionName should be specified.") if collectionName is undefined
            @name = "#{db.name}_#{collectionName}"
            @ls = db.ls
            @deserialize()

        ###
         *  get data and tranfer into object from localStorage/sessionStorage
        ###
        deserialize: -> @data = Utils.parse @ls.getItem(@name)

        ###
         *  save data into localStorage/sessionStorage
         *  when catching error in setItem(), delete the oldest data and try again.
        ###
        serialize: ->
            try
                @ls.setItem @name, Utils.stringify(@data)
            catch e
                flag = true
                while flag
                    try
                        @data.splice(0,1)
                        @ls.setItem @name, Utils.stringify(@data)
                        flag = false
            return

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
            data = Operation.find(@data, options)[0]
            if data? then data else {}

    module.exports = Collection