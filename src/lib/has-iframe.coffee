define (require, exports, module) ->
    'use strict'

    class hasIframe
        iframe = null
        constructor: (@src) ->
            self = @
            allFrame = document.getElementsByTagName("iframe");
            for frames in allFrame
                if frames.src is self.src
                    iframe = frames
                    break 
            return iframe

    module.exports = hasIframe