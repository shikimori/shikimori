using 'DynamicElements'
class DynamicElements.CodeHighlight extends View
  VERSION = '9.9.0'
  THEME = 'agate'
  HLJS_CDN_ROOT = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/#{VERSION}"

  initialize: ->
    @klass = DynamicElements.CodeHighlight

    @highlight() if @is_initialized()

  highlight: ->
    hljs.highlightBlock @root.childNodes[0]

  is_initialized: ->
    return true if @klass.hljs_initialized

    @klass.queue ||= []
    @klass.queue.push @

    unless @klass.hljs_initializing
      @klass.hljs_initializing = true

      style = document.createElement 'link'
      style.rel = 'stylesheet'
      style.href = "#{HLJS_CDN_ROOT}/styles/#{THEME}.min.css"
      document.head.appendChild(style)

      script = document.createElement 'script'
      script.onload = @klass.hljs_callback
      script.src = "#{HLJS_CDN_ROOT}/highlight.min.js"
      document.head.appendChild(script)

    false

  @hljs_callback: ->
    DynamicElements.CodeHighlight.hljs_initialized = true
    DynamicElements.CodeHighlight.queue.each (code_highlight) ->
      code_highlight.highlight()

    DynamicElements.CodeHighlight.queue = []
