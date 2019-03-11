import delay from 'delay'

import flash from 'services/flash'
import csrf from 'helpers/csrf'

I18N_KEY = 'frontend.lib.jquery_shiki_file'

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

      csrf_tokens = csrf()
      $node.filedrop
        url: $node.data('upload_url')
        paramname: 'image'
        data: csrf_tokens.post
        headers: csrf_tokens.headers
        allowedfiletypes: [
          'image/jpg'
          'image/jpeg'
          'image/png'
        ]
        error: (status, _file, _fileIndex, _status, error) ->
          @afterAll()

          switch status
            when 'TooManyFiles'
              flash.error I18n.t("#{I18N_KEY}.too_many_files", count: options.maxfiles)

            when 'FileTooLarge'
              flash.error I18n.t("#{I18N_KEY}.too_large_file")

            when 'Unprocessable Entity'
              if (error)
                flash.error error
              else
                flash.error I18n.t("#{I18N_KEY}.please_try_again_later")

            when 'FileTypeNotAllowed'
              flash.error I18n.t("#{I18N_KEY}.file_type_not_allowed")

            #when 'BrowserNotSupported'
            else
              flash.error I18n.t("#{I18N_KEY}.browser_not_supported")

          global_lock = false

        maxfiles: options.maxfiles
        maxfilesize: 4 # max file size in MBs
        queuefiles: 1
        refresh: 50

        beforeEach: (file) ->
          #$progress_bar.width '0%'
          filename = file.name
          filesize = Math.ceil(file.size / 10) / 100
          $progress_bar.html(
            I18n.t "#{I18N_KEY}.loading_file",
              filename: filename,
              filesize: filesize
          )

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
          delay(250).then -> $progress_bar.width '0%'

        docOver: (e) ->
          if $node.data('placeholder_displayed') || !$node.is(':visible')
            return

          $node.data placeholder_displayed: true

          height = $node.outerHeight()
          width = $node.outerWidth()
          text =
            if global_lock
              I18n.t("#{I18N_KEY}.wait_till_loaded")
            else
              I18n.t("#{I18N_KEY}.drop_pictures_here")
          cls = if global_lock then 'disallowed' else 'allowed'

          $placeholder = $("<div data-text='#{text}' class='b-dropzone-drag_placeholder #{cls}' style='width:#{width}px!important;height:#{height}px;line-height:#{Math.max(height, 75)}px;'></div>")
            .css(opacity: 0)
            .on('drop', (e) -> $node.trigger e)
            .on('dragenter', -> $(@).addClass 'hovered')
            .on('dragleave', -> $(@).removeClass 'hovered')
            .insertBefore($node)

          delay().then -> $placeholder.css opacity: 0.75

        docLeave: (e) ->
          return unless $node.data 'placeholder_displayed'

          $placeholder = $node.parent()
            .find('.b-dropzone-drag_placeholder')
            .css(opacity: 0)

          delay(350).then -> $placeholder.remove()
          $node.data placeholder_displayed: false

        uploadStarted: (i, file, len) ->
          $node.trigger 'upload:started', i
          #$.cursorMessage()
          #$progress_bar.html 'загрузка файла...'

        uploadFinished: (i, file, response, time) ->
          if Object.isString(response) || 'error' of response
            $node.trigger 'upload:failed', [response, i]
            alert =
              if Object.isString(response)
                I18n.t("#{I18N_KEY}.please_try_again_later")
              else
                response.error

            flash.error alert
          else
            $node.trigger 'upload:success', [response, i]
          #$.hideCursorMessage()

        progressUpdated: (i, file, progress) ->
          if progress > 85 || i > 0
            #$progress_bar.html 'загрузка на картинкохостинг...'
            $progress_bar.width '100%'
          else
            $progress_bar.width progress+'%'


      $node.pastableTextarea()
      $node.on 'pasteImage', (e, data) ->
        file = new File(
          [data.blob],
          "pasted_file.#{data.blob.type.split('/')[1]}",
          type: data.blob.type,
          lastModified: Date.now()
        )
        $node.trigger 'drop', [[file]]
