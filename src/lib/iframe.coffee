define (require, exports, module) ->

    'use strict'

    class Iframe

        constructor: (@origin) ->

        create: (content) ->
            return if document.getElementById(@origin)?
            @ifrm = document.createElement "IFRAME"
            @ifrm.setAttribute "src", @origin
            @ifrm.setAttribute "id", @origin
            @ifrm.style.width = "1px"
            @ifrm.style.height = "1px"
            @ifrm.style.display = "none"
            document.body.appendChild(@ifrm)
            return
        remove: -> @ifrm.parentElement.removeChild(@ifrm)
