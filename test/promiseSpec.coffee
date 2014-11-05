define (require, exports, module) ->

    "use strict"
    Promise = require("lib/promise")

    describe "Promise", ->
        it "Init", ->
            console.log "Promise Init"
            promise = new Promise((resolve, reject) ->
                resolve(100)
                )

            promise.then((x) ->
                console.log("Promise:then done!!!")
                expect(x).toEqual(100)
                )

        
