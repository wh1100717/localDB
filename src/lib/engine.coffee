'use strict'

Support = require('./support')

class Engine

    constructor: (type) ->
        @type = if type is 2 then 2 else 1
        if not Support.sessionstorage()
            throw new Error("sessionstorage is not supported!") if type is 1
            throw new Error("no browser storage engine is supported in your browser!") if Support.userdata()
            @type = 2
        return
        
    key: (name) ->
        if @type is 1
            return sessionStorage.key(name)
        else if Support.localstorage()
            return localStorage.key(name)
        else
            console.log "userdata TODO"

    size: ->
        if @type is 1
            return sessionStorage.length
        else if Support.localstorage()
            return localStorage.length
        else
            console.log "userdata TODO"

    setItem: (key, val) ->
        if @type is 1
            return sessionStorage.setItem(key, val)
        else if Support.localstorage()
            return localStorage.setItem(key, val)
        else
            console.log "userdata TODO"

    getItem: (key) ->
        if @type is 1
            return sessionStorage.getItem(key)
        else if Support.localstorage()
            return localStorage.getItem(key)
        else
            console.log "userdata TODO"

    removeItem: (key) ->
        if @type is 1
            return sessionStorage.removeItem(key)
        else if Support.localstorage()
            return localStorage.removeItem(key)
        else
            console.log "userdata TODO"

module.exports = Engine


