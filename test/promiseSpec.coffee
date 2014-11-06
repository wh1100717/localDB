define (require, exports, module) ->

    "use strict"
    Promise = require("lib/promise")

    describe "Promise", ->
        it "Init", ->
            promise = new Promise((resolve, reject) ->
                resolve(100)
                )

            promise.then((x) ->
                expect(x).toEqual(100)
                )

        
