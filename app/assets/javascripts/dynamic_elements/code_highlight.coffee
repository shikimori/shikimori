import View from 'views/application/view'

export default class CodeHighlight extends View
  NO_HIGHLIGHT = 'nohighlight'

  initialize: ->
    @klass = CodeHighlight
    @klass.hljs_initialize()

    @highlight()

  highlight: ->
    node = @root.childNodes[0]
    language = @root.attributes['data-language']?.value

    return if node.classList.contains NO_HIGHLIGHT
    return unless language

    if Modernizr.bloburls && Modernizr.webworkers
      node.id = "code_#{@klass.last_id}"
      @klass.last_id += 1

      @klass.worker.postMessage
        node_id: node.id
        code: node.textContent
        language: language
    else
      console.error 'webworkers are not supported'
      # hljs.highlightBlock node

  # hljs usage example https://highlightjs.org/usage/
  @hljs_initialize: ->
    return if @hljs_initialized
    @hljs_initialized = true
    @last_id = 0

    @worker = @build_worker ->
      importScripts(
        'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js'
      )
      # importScripts(
        # 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js',
        # 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/yaml.min.js'
      # )
      # не убирать @. без этого uglifier переименует переменную onmessage
      @onmessage = (event) ->
        result = self.hljs.highlight event.data.language, event.data.code, true
        postMessage
          html: result.value
          node_id: event.data.node_id
      return

    @worker.onmessage = (event) ->
      document.getElementById(event.data.node_id)?.innerHTML = event.data.html

  @build_worker: (func) ->
    code = func.toString()
    code = code.substring(code.indexOf('{') + 1, code.lastIndexOf('}'))
    blob = new Blob([ code ], type: 'application/javascript')
    worker = new Worker(URL.createObjectURL(blob))
