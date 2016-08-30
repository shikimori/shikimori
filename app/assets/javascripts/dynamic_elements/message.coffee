#= require dynamic_elements/comment
using 'DynamicElements'
class DynamicElements.Message extends DynamicElements.Comment
  _type: -> 'message'
  _type_label: -> 'Сообщение'
