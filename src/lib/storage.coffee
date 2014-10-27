define (require, exports, module) ->
    
    'use strict'

    Support = require('lib/support')

    UserData = require('lib/userdata')

    class Storage

        constructor: (@session) ->
            if @session
                throw new Error("sessionStorage is not supported!") if not Support.sessionstorage()
            else if not Support.localstorage()
                throw new Error("no browser storage engine is supported in your browser!") if not Support.userdata()
                @userdata = new UserData()

        key: (index) -> (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).key(index)

        size: ->
            if @session
                return sessionStorage.length
            else if Support.localstorage()
                return localStorage.length
            else
                return @userdata.size()

        setItem: (key, val) -> (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).setItem(key, val)

        getItem: (key) -> (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).getItem(key)

        removeItem: (key) -> (if @session then sessionStorage else (if @userdata? then @userdata else localStorage)).removeItem(key)

        usage: ->
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
            return allStrings.length / 512

    module.exports = Storage