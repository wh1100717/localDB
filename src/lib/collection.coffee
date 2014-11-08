define (require, exports, module) ->
    'use strict'

    Utils = require('lib/utils')
    Operation = require('lib/operation')
    Promise = require('lib/promise')
    class Collection

        ###
         *  in LocalDB, only use LocalDB to get a collection.
         *  db = new LocalDB('foo')
         *  var collection = db.collection('bar')
        ###
        constructor: (collectionName, engine) ->
            throw new Error("collectionName should be specified.") if collectionName is undefined
            @name = "#{engine.name}_#{collectionName}"
            @engine = engine

        ###
         *  get data and tranfer into object from localStorage/sessionStorage
        ###
        deserialize: (callback) ->
            self = @
            @engine.getItem @name, (data, err) ->
                data = Utils.parse data
                callback(data, err) if callback?

        ###
         *  save data into localStorage/sessionStorage
         *  when catching error in setItem(), delete the oldest data and try again.
        ###
        serialize: (data, callback) ->
            @engine.setItem @name, Utils.stringify(data), (err) ->
                callback(err) if callback?

        ###
         *  delete this collection
        ###
        drop: (callback) -> @engine.removeItem @name, callback

        ###
         *  insert data into collection
        ###
        insert: (rowData, paras...) ->
            [options, callback] = Utils.parseParas(paras)
            self = @
            promiseFn = (resolve, reject) ->
                self.deserialize (data, err) ->
                    if err
                        callback(err) if callback?
                        reject(err)
                    else
                        data = Operation.insert data, rowData, options
                        self.serialize data, (err) ->
                        callback(err) if callback?
                        if err
                            reject(err)
                        else
                            resolve(1)
            new Promise(promiseFn)

        ###
         *  update collection
        ###
        update: (actions, paras...) ->
            [options, callback] = Utils.parseParas(paras)
            self = @
            promiseFn = (resolve, reject) ->
                self.deserialize (data, err) ->
                    if err
                        callback(err) if callback?
                        reject(err)
                    else
                        data = Operation.update data, actions, options
                        self.serialize data, (err) ->
                            callback(err) if callback?
                            if err
                                reject(err)
                            else
                                resolve(data)
            new Promise(promiseFn)

        ###
         *  remove data from collection
        ###
        remove: (paras...) ->
            [options, callback] = Utils.parseParas(paras)
            self = @
            promiseFn = (resolve, reject) ->
                self.deserialize (data, err) ->
                if err
                    callback(err) if callback?
                    reject(err)
                else
                    data = Operation.remove data, options
                    self.serialize data, (err) ->
                        callback(err) if callback?
                        if err
                            reject(err)
                        else
                            resolve(data)
            new Promise(promiseFn)

        ###
         * find data from collection
        ###
        find: (paras...) ->
            [options, callback] = Utils.parseParas(paras)
            self = @
            promiseFn = (resolve, reject) ->
                self.deserialize (data, err) ->
                    if err
                        callback([], err) if callback?
                        reject(err)
                    else
                        data = Operation.find data, options
                        callback(data, err) if callback?
                        if err
                            reject(err)
                        else
                            resolve(data)
            new Promise(promiseFn)

        ###
         *  find data and only return one data from collection
        ###
        findOne: (paras...) ->
            [options, callback] = Utils.parseParas(paras)
            options.limit = 1
            self = @
            promiseFn = (resolve, reject) ->
                self.deserialize (data, err) ->
                    if err
                        callback([], err) if callback?
                        reject(err)
                    else
                        data = Operation.find data, options
                        data.push(undefined) if data.length is 0
                        callback((data[0]), err) if callback?
                        if err
                            reject(err)
                        else
                            resolve(data[0])
            new Promise(promiseFn)


    module.exports = Collection