(($) ->
  defaults =
    maxfiles: 150
    progress: null
    input: null

  global_lock = false

  $.fn.extend
    shikiFile: (opts) ->
      @each ->
        options = $.extend {}, defaults, opts
        $node = $ @

        # плейсхолдер того места, куда будет класться файл
        $placeholder = null

        # прогресс-бар
        $progress_container = $(options.progress)
        $progress_bar = $progress_container.children()

        $input = $(options.input)
        # выбор файла в инпуте - триггер файлдропа
        $input.change ->
          if @files.length > 0
            $node.trigger 'drop', [@files]

        $node.filedrop
          #fallback_id: 'upload_button',    # an identifier of a standard file input element
          url: $node.data('upload_url'),   # upload handler, handles each file separately
          paramname: 'image',      # POST parameter name used on serverside to reference file
          data: CSRF.post,
          headers: CSRF.headers,
          error: (err, file) ->
            switch err
              when 'BrowserNotSupported'
                $.flash alert: 'Ваш браузер не поддерживает данный функционал'

              when 'TooManyFiles'
                $.flash alert: "Слишком много файлов: максимум #{options.maxfiles} за раз"

              when 'FileTooLarge'
                $.flash alert: 'Файл слишком большой: максимум 4 мегабайта'

              when 'Unprocessable Entity'
                $.flash alert: 'Пожалуста, повторите попытку позже'

            global_lock = false

          maxfiles: options.maxfiles,
          maxfilesize: 4, # max file size in MBs
          queuefiles: 1
          refresh: 50

          beforeEach: (file) ->
            #$progress_bar.width '0%'
            $progress_bar.html "загрузка файла #{file.name} (#{Math.ceil(file.size / 10) / 100} Кб) ..."

          drop: ->
            return false if global_lock
            global_lock = true
            $node.trigger 'upload:before'
            $(document.body).trigger 'dragleave'

            $progress_container.addClass 'active'

          afterAll: ->
            $node.trigger 'upload:after'
            global_lock = false

            $progress_container.removeClass 'active'
            _.delay ->
              $progress_bar.width '0%'
            , 250

          docOver: ->
            return if $node.data('placeholder_displayed') || !$node.is(':visible')

            $node.data placeholder_displayed: true

            height = $node.outerHeight()
            width = $node.outerWidth()
            text = if global_lock then 'Дождитесь загрузки файлов' else 'Перетаскивайте сюда картинки'
            cls = if global_lock then 'disallowed' else 'allowed'

            $placeholder = $("<div class='drag-placeholder #{cls}' style='width:#{width}px!important;height:#{height}px;line-height:#{Math.max(height, 75)}px;'>#{text}</div>")
              .css(opacity: 0)
              .on('drop', (e) -> $node.trigger e)
              .on('dragenter', -> $(@).addClass 'hovered')
              .on('dragleave', -> $(@).removeClass 'hovered')
              .insertBefore($node)

            _.delay ->
              $placeholder.css opacity: 0.75

          docLeave: (e) ->
            #return
            return unless $node.data 'placeholder_displayed'

            $placeholder = $node.parent()
                .find('.drag-placeholder')
                .css opacity: 0
            _.delay ->
              $placeholder.remove()
            , 350
            $node.data placeholder_displayed: false

          uploadStarted: (i, file, len) ->
            $node.trigger 'upload:started', i
            #$.cursorMessage()
            #$progress_bar.html 'загрузка файла...'

          uploadFinished: (i, file, response, time) ->
            if _.isString(response) || 'error' of response
              $node.trigger 'upload:failed', [response, i]
              $.flash alert: if _.isString(response) then 'Пожалуста, повторите попытку позже' else response.error
            else
              $node.trigger 'upload:success', [response, i]
            #$.hideCursorMessage()

          progressUpdated: (i, file, progress) ->
            if progress > 85 || i > 0
              #$progress_bar.html 'загрузка на картинкохостинг...'
              $progress_bar.width '100%'
            else
              $progress_bar.width progress+'%'
)(jQuery)
