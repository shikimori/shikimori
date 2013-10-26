(($) ->
  if history && history.navigationMode
    history.navigationMode = 'compatible';

  $.extend
    form_navigate: (options) ->
      $(document.body).on 'change keydown', 'textarea', ->
        $(@).addClass 'form-navigate-check'

      $(document.body).on 'submit', 'form', ->
        $(@).find('textarea').removeClass 'form-navigate-check'

      $(window).on 'beforeunload', ->
        changes = false

        $('textarea.form-navigate-check:visible').each(->
          $(@).removeClass 'form-navigate-check'
          changes = true if $(@).val().length > options.size
        )

        options.message if changes

) jQuery
