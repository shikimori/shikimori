using 'DynamicElements'
class DynamicElements.AuthorizedAction extends View
  @I18N_KEY = 'frontend.dynamic_elements.authorized_action'

  initialize: ->
    @$node.on 'click', (e) ->
      unless USER_SIGNED_IN
        $.info t(I18N_KEY)
        e.stopImmediatePropagation()
        falst
