if history && history.navigationMode
  history.navigationMode = 'compatible'

$.extend
  formNavigate: (options) ->
    $(document.body).on 'change keypress', 'textarea', ->
      $(@).data navigate_check_required: true

    $(document.body).on 'submit', 'form', ->
      $(@).find('textarea').data navigate_check_required: false

    $(window).on 'beforeunload page:before-change', (e) ->
      changes = false

      $('textarea:visible').each ->
        $node = $(@)
        return unless $node.data('navigate_check_required')
        $node.data navigate_check_required: false
        changes = true if $node.val().length > options.size

      if changes
        if e.type == 'page:before-change'
          confirm options.message
        else
          options.message
