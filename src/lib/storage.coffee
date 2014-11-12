define (require, exports, module) ->
    'use strict'

    Support = require('lib/support')
    Utils = require('lib/utils')
    Encrypt = require('lib/encrypt')

    class Storage

        constructor: (@session, @encrypt, @token) ->
            if @session
                throw new Error("sessionStorage is not supported!") if not Support.sessionstorage()
                @storage = sessionStorage
            else
                throw new Error("localStorage is not supported!") if not Support.localstorage()
                @storage = localStorage

        key: (index, callback) ->
            try
                key = @storage.key(index)
            catch e
                callback(-1, e)
            callback(key)
            return

        size: (callback) ->
            try
                size = @storage.length
            catch e
                callback(-1, e)
            callback(size)
            return

        setItem: (key, val, callback) ->
            self = @
            try
                val = Encrypt.encode(val, @token) if @encrypt
                @storage.setItem(key, val)
            catch e
                ### TODO
                 *  需要在LocalDB的构造函数中增加配置参数，来确定是否自动删除最老数据
                 *  增加过期时间配置项
                ###
                ### TODO
                 *  这里有可能是非容量满等其他原因导致出错
                 *  所以需要设置一个最大尝试阀值，或者根据出错信息来判断是否继续循环
                 *  避免死循环
                ###
                flag = true
                val = Encrypt.decode(val, @token) if @encrypt
                data = Utils.parse val
                while flag
                    try
                        data.splice(0, 1)
                        val = Utils.stringify(data)
                        val = Encrypt.encode(val, self.token) if self.encrypt
                        self.storage.setItem(key, val)
                        flag = false
            ### TODO
             *  目前采用的是删除初始数据来保证在数据存满以后仍然可以继续存下去
             *  在初始化LocalDB的时候需要增加配置参数，根据参数来决定是否自动删除初始数据，还是返回e
            ###
            callback()
            return

        getItem: (key, callback) ->
            try
                item = @storage.getItem(key)
                item = Encrypt.decode(item, @token) if @encrypt
            catch e
                callback(null, e)
            callback(item)
            return

        removeItem: (key, callback) ->
            try
                @storage.removeItem(key)
            catch e
                callback(e)
            callback()
            return

        usage: (callback) ->
            ###
             *  check it out: http://stackoverflow.com/questions/4391575/how-to-find-the-size-of-localstorage
            ###
            try
                allStrings = ""
                for key, val of @storage
                    allStrings += val
            catch e
                callback(-1, e)
            callback(allStrings.length / 512)

    module.exports = Storage