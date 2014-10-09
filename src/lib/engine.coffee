'use strict'

class Engine

    constructor: (engine) ->
        if engine is localStorage
            @type = 1
        else if engine is sessionStorage
            @type = 2
        else if engine is indexedDB
            @type = 3
        else
            @type = 9
    key: (name) ->
        switch @type
            when 1 then return localStorage.key(name)
            when 2 then return sessionStorage.key(name)

    size: ->
        switch @type
            when 1 then return localStorage.length
            when 2 then return sessionStorage.length

    setItem: (key, val) ->
        switch @type
            when 1 then return localStorage.setItem(key, val)
            when 2 then return sessionStorage.setItem(key, val)

    getItem: (key) ->
        switch @type
            when 1 then return localStorage.getItem(key)
            when 2 then return sessionStorage.getItem(key)            

    removeItem: (key) ->
        switch @type
            when 1 then return localStorage.removeItem(key)
            when 2 then return sessionStorage.removeItem(key)            

module.exports = Engine        


