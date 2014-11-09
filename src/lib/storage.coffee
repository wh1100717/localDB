define (require, exports, module) ->
    
    'use strict'

    Support = require('lib/support')
    UserData = require('lib/userdata')
    Utils = require('lib/utils')
    Encrypt = require('lib/encrypt')

    class Storage

        constructor: (@session, @encrypt, @token) ->
            if @session
                throw new Error("sessionStorage is not supported!") if not Support.sessionstorage()
            else if not Support.localstorage()
                throw new Error("no browser storage engine is supported in your browser!") if not Support.userdata()
                @userdata = new UserData()

        key: (index, callback) ->
            try
                key = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).key(index)
            catch e
                callback(-1, e)
            callback(key)
            return

        size: (callback) ->
            try
                if @session
                    size = sessionStorage.length
                else if Support.localstorage()
                    size = localStorage.length
                else
                    size = @userdata.size()
            catch e
                callback(-1, e)
            callback(size)
            return

        setItem: (key, val, callback) ->
            ls = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage))
            try
                if @encrypt
                    val = Encrypt.encode(val, @token)
                ls.setItem(key, val)
            catch e
                flag = true
                data = Utils.parse val
                while flag
                    try
                        data.splice(0, 1)
                        ls.setItem(key, Utils.stringify(data))
                        flag = false
            ### TODO
             *  目前采用的是删除初始数据来保证在数据存满以后仍然可以继续存下去
             *  在初始化LocalDB的时候需要增加配置参数，根据参数来决定是否自动删除初始数据，还是返回e
            ###
            callback()
            return

        getItem: (key, callback) ->
            try
                item = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).getItem(key)
                if @encrypt
                    item = Encrypt.decode(item, @token)
            catch e
                callback(null, e)
            callback(item)
            return

        removeItem: (key, callback) ->
            try
                (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).removeItem(key)
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
                if @tyep is 1
                    for key, val of sessionStorage
                        allStrings += val
                else if Support.localstorage()
                    for key, val of localStorage
                        allStrings += val
                else
                    console.log "todo"
            catch e
                callback(-1, e)
            callback(allStrings.length / 512)

    module.exports = Storage