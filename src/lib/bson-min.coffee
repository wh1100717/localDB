'use strict'

BinaryParser = require('./binary-parser')

hexTable = ((if i <= 15 then '0' else '') + i.toString(16) for i in [0...256])

MACHINE_ID = parseInt(Math.random() * 0xFFFFFF, 10)

checkForHexRegExp = /^[0-9a-fA-F]{24}$/

ObjectID = (id, _hex) ->
    return new ObjectID(id, _hex) if not @ instanceof ObjectID
    @_bsontype = 'ObjectID'
    __id = null
    if id? and 'number' isnt typeof id and id.length isnt 12 and id.length isnt 24
        throw new Error("Argument passed in must be a single String of 12 bytes or a string of 24 hex characters")
    if not id? or typeof id is 'number'
        @id = @generate(id)
    else if id? and id.length is 12
        @id = id
    else if checkForHexRegExp.test(id)
        return ObjectID.createFromHexString(id)
    else
        throw new Error("Value passed in is not a valid 24 character hex string")
    @__id = @toHexString() if ObjectID.cacheHexString

ObjectID.prototype.generate = (time) ->
    if 'number' is typeof time
        time4Bytes = BinaryParser.encodeInt(time, 32, true, true)
        machine3Bytes = BinaryParser.encodeInt(MACHINE_ID, 24, false)
        pid2Bytes = BinaryParser.fromShort(if typeof process is 'undefined' then Math.floor(Math.random() * 100000) else process.pid)
        index3Bytes = BinaryParser.encodeInt(@get_inc(), 24, false, true)
    else
        unixTime = parseInt(Date.now() / 1000, 10)
        time4Bytes = BinaryParser.encodeInt(unixTime, 32, true, true)
        machine3Bytes = BinaryParser.encodeInt(MACHINE_ID, 24, false)
        pid2Bytes = BinaryParser.fromShort(if typeof process is 'undefined' then Math.floor(Math.random() * 100000) else process.pid)
        index3Bytes = BinaryParser.encodeInt(@get_inc(), 24, false, true)
    return time4Bytes + machine3Bytes + pid2Bytes + index3Bytes

ObjectID.prototype.toHexString = ->
    return @__id if ObjectID.cacheHexString and @__id
    hexString = ''
    for i in [0...@id.length]
        hexString += hexTable[@id.charCodeAt(i)]
    @__id = hexString if ObjectID.cacheHexString
    return hexString

ObjectID.prototype.toString = -> @toHexString()

ObjectID.prototype.inspect = ObjectID.prototype.toString

ObjectID.prototype.getTimestamp = ->
    timestamp = new Date()
    timestamp.setTime(Math.floor(BinaryParser.decodeInt(@id.substring(0, 4), 32, true, true)) * 1000)
    return timestamp

ObjectID.prototype.get_inc = ->
    return ObjectID.index = (ObjectID.index + 1) % 0xFFFFFF

ObjectID.index = parseInt(Math.random() * 0xFFFFFF, 10)

ObjectID.createFromHexString = (hexString) ->
    if not hexString? or hexString.length isnt 24
        throw new Error("Argument passed in must be a single String of 12 bytes or a string of 24 hex characters");
    result =''
    for i in [0...24] when i % 2 is 0
        result += BinaryParser.fromByte(parseInt(hexString.substr(i, 2), 16))
    return new ObjectID(result, hexString)

module.exports = ObjectID





