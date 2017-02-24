using 'DynamicElements'
class DynamicElements.CodeHighlight extends View
  NO_HIGHLIGHT = 'nohighlight'

  initialize: ->
    @klass = DynamicElements.CodeHighlight
    @klass.hljs_initialize()

    @highlight()

  highlight: ->
    node = @root.childNodes[0]
    return if node.classList.contains(NO_HIGHLIGHT)

    if Modernizr.bloburls && Modernizr.webworkers
      node.id = "code_#{@klass.last_id}"
      @klass.last_id += 1

      @klass.worker.postMessage
        node_id: node.id
        code: node.textContent
    else
      console.error 'webworkers are not supported'
      # hljs.highlightBlock node

  # hljs usage example https://highlightjs.org/usage/
  @hljs_initialize: ->
    return if @hljs_initialized
    @hljs_initialized = true
    @last_id = 0

    @worker = build_worker ->
      importScripts(
        'https://cdnjs.cloudflare.com/ajax/libs/highlight.js' +
          '/9.9.0/highlight.min.js'
      )
      # не убирать @. без этого uglifier переименует переменную onmessage
      @onmessage = (event) ->
        result = self.hljs.highlightAuto(event.data.code)
        postMessage
          html: result.value
          node_id: event.data.node_id
      return

    @worker.onmessage = (event) ->
      document.getElementById(event.data.node_id)?.innerHTML = event.data.html
