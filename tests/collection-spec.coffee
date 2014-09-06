'use strict'
expect = require('expect.js')
LocalDB = require('../src/localdb.js')
Collection = require('../src/lib/collection.js')

db = new LocalDB("foo")

describe 'Collection', ->
    it 'Collection Init', ->
        #第一种collection初始化方式
        collection = db.collection("bar")
        expect(collection).to.be.ok()
        #第二种collection初始化方式
        collection = new Collection("bar", db)
        expect(collection).to.be.ok()
        



