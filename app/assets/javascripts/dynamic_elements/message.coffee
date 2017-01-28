#= require dynamic_elements/comment
using 'DynamicElements'
class DynamicElements.Message extends DynamicElements.Comment
  _type: -> 'message'
  _type_label: -> t('frontend.dynamic_elements.message.type_label')

  _deactivate_inaccessible_buttons: ->
