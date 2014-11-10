define (require, exports, module) ->
    'use strict'
    Utils = require('lib/utils')

    Sort = {}
    
    ###
      * 快速排序
      * @param array 待排序数组
      * @param key 排序字段
      * @param order 排序方式（1:升序，-1降序）
    ###
    Sort.quickSort = (array, key, order) ->
        return array if array.length <= 1        
        ##pointValue = array[pointIndex]会死循环
        pointValue = array.splice(0, 1)[0]
        pointCompareValue = Utils.getSubValue(pointValue, key)          
        leftArr = []
        rightArr = []

        for value in array
            compareValue = Utils.getSubValue(value, key)
            ##属性不存在则算最小值            
            if not compareValue? or compareValue < pointCompareValue          
                leftArr.push value
            else
                rightArr.push value

        if order >= 1                            
            Sort.quickSort(leftArr, key, order).concat([pointValue], Sort.quickSort(rightArr, key, order))
        else
            Sort.quickSort(rightArr, key, order).concat([pointValue], Sort.quickSort(leftArr, key, order))

    ###
      * 数据排序
    ###
    Sort.sort = (data, sortObj) ->
        sortArr = []
        for key, order of sortObj
            sortArr.unshift({
                key : key
                order : order
            })
        
        result = data
        for sort in sortArr            
            result = Sort.quickSort(result, sort.key, sort.order)
            console.log(result)
        return result

    module.exports = Sort

