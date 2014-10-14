'use strict'

class Engine

    constructor: (type) ->
        @type = if type is 2 then 2 else 1
        
    key: (name) ->
        return sessionStorage.key(name) if @type is 1
        return localStorage.key(name) if @type is 2

    size: ->
        return sessionStorage.length if @type is 1
        return localStorage.length if @type is 2

    setItem: (key, val) ->
        return sessionStorage.setItem(key, val) if @type is 1
        return localStorage.setItem(key, val) if @type is 2

    getItem: (key) ->
        return sessionStorage.getItem(key) if @type is 1
        return localStorage.getItem(key) if @type is 2

    removeItem: (key) ->
        return sessionStorage.removeItem(key) if @type is 1
        return localStorage.removeItem(key) if @type is 2

module.exports = Engine


