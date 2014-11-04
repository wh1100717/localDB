define (require, exports, module) ->

    'use strict'
    ###
     *  https://github.com/wh1100717/evemit
    ###
    _isIE = if window.addEventListener? then false else true

    evemit = evemit or (obj) -> obj[i] = j for i,j of evemit.prototype;obj

    evemit.bind = (el, eve, fn, priority) ->
        el[if _isIE then "attachEvent" else "addEventListener"]("#{if _isIE then 'on' else ''}#{eve}", fn, priority or false)

    evemit.unbind = (el, eve, fn, priority) ->
        el[if _isIE then "detachEvent" else "removeEventListener"]("#{if _isIE then 'on' else ''}#{eve}", fn, priority or false)

    evemit.prototype.on = (eve, fn) ->
        @events = {} if not @events?
        @events[eve] = [] if not @events[eve]?
        @events[eve].push(fn);@

    evemit.prototype.once = (eve, fn) ->
        @events = {} if not @events?
        @.on(eve, -> evemit.prototype.off(eve);fn.apply(@, arguments));@

    evemit.prototype.off = (eve) ->
        if @events? then delete @events[eve];@ else @

    evemit.prototype.emit = (eve, args...) ->
        if @events? and @events[eve]? then (e.apply(this, args) for e in @events[eve]);@ else @

    evemit.prototype.events = ->
        e for e of @events

    evemit.prototype.listeners = (eve) ->
        @events = {} if not @events?
        l for l in @events[eve]

    module.exports = evemit