define (require, exports, module) ->
    
    'use strict'

    Support = require('lib/support')
    UserData = require('lib/userdata')
    Utils = require('lib/utils')
    err = null

    class Storage

        constructor: (@session) ->
            if @session
                throw new Error("sessionStorage is not supported!") if not Support.sessionstorage()
            else if not Support.localstorage()
                throw new Error("no browser storage engine is supported in your browser!") if not Support.userdata()
                @userdata = new UserData()

        key: (index, callback) ->
            key = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).key(index)

            if typeof callback is 'function'
                callback(key, err)
                return
            else
                return key

        size: (callback) ->
            if @session
                size = sessionStorage.length
            else if Support.localstorage()
                size = localStorage.length
            else
                size = @userdata.size()

            if typeof callback is 'function'
                callback(size, err)
                return
            else
                return size

        setItem: (key, val, callback) ->
            ls = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage))
            try
                ls.setItem(key, val)
            catch e
                flag = true
                data = Utils.parse val
                while flag
                    try
                        data.splice(0, 1)
                        ls.setItem(key, Utils.stringify(data))
                        flag = false
            if typeof callback is 'function'
                callback(err)
                return
            else
                return

        getItem: (key, callback) ->
            item = (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).getItem(key)
            if typeof callback is 'function'
                callback(item, err)
                return
            else
                return

        removeItem: (key, callback) ->
            (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).removeItem(key)
            if typeof callback is 'function'
                callback(err)
                return
            else
                return

        usage: (callback) ->
            ###
             *  check it out: http://stackoverflow.com/questions/4391575/how-to-find-the-size-of-localstorage
            ###
            allStrings = ""
            if @tyep is 1
                for key, val of sessionStorage
                    allStrings += val
            else if Support.localstorage()
                for key, val of localStorage
                    allStrings += val
            else
                console.log "todo"
            u = allStrings.length / 512
            if typeof callback is 'function'
                callback(u, err)
                return
            else
                return

    module.exports = Storage