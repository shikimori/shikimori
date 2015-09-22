class @AbuseRequest extends View
  initialize: ->
    @$('.moderation .take, .moderation .deny').on 'ajax:before', =>
      #$comment(@).shiki()._reload()
      @$('.moderation').remove()
      @$('.spoiler.collapse').remove()
      @_reload()
