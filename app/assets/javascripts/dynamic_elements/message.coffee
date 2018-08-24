import Comment from './comment'

export default class Message extends Comment
  _type: -> 'message'
  _type_label: -> I18n.t('frontend.dynamic_elements.message.type_label')

  _deactivate_inaccessible_buttons: ->
