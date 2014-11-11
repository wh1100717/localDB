define (require, exports, module) ->

    "use strict"
    Promise = require("lib/promise")

    describe "Promise", ->
        it "then resolve", ->
            promise = new Promise((resolve, reject) ->
                    setTimeout(->
                        resolve 100
                    , 300)
                )
            promise.then((val) ->
                expect(val).toEqual(100)
                val
            ).then((val) ->
                expect(val).toEqual(100)
            ).then((val) ->
                expect(val).toBeUndefined()
            )
        it "then reject", ->
            promise = new Promise((resolve, reject) ->
                    setTimeout(->
                        reject 'reject:err'
                    , 300)
                )
            promise.then(
                    ->
                ,(err) ->
                    expect(err).toEqual(reject:err)
                ).then(
                    ->
                ,(err)->
                    expect(err).toBeUndefined()
                )
        it "done", ->
            promise = new Promise((resolve, reject) ->
                    setTimeout(->
                        resolve 100
                    , 300)
                )
            promise.done((val) ->
                    expect(val).toEqual(100)
                )
        it "return promise", ->
            promise = new Promise((resolve, reject) ->
                    setTimeout(->
                        resolve 100
                    , 300)
                )
            promise.then((val) ->
                    new Promise((resolve, reject) ->
                            resolve(val)
                        )
                ).then((val) ->
                        expect(val).toEqual(100)
                    )        

        
