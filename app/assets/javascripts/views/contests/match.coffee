using 'Contests'
module.exports = class Contests.Match extends View
  initialize: (@vote, @round_view) ->
    @model = @$root.data('model')

    if @_is_started()
      # подсветка по ховеру курсора
      @$('.match-member').hover (e) =>
        unless @$('.match-member.voted').length
          @$('.match-member').addClass('unhovered')
          $(e.target).removeClass('unhovered').addClass('hovered')
      , =>
        @$('.match-member').removeClass('hovered unhovered')

    # пометка проголосованным, если это указано
    # variant = $('.contest-match', e.target).data 'voted'
    # if variant
      # $('.refrain', e.target).trigger 'ajax:success'

  _is_started: ->
    @model.state == 'started'
