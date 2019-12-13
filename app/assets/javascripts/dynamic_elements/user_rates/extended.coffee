import JST from 'helpers/jst'
import axios from 'helpers/axios'
import UserRateButton from './button'

export default class UserRateExtended extends UserRateButton
  EXTENDED_TEMPLATE = 'user_rates/extended'
  SCORE_TEMPLATE = 'user_rates/score'

  initialize: ->
    @entry = @$root.data('entry')
    @form_html = null

    @on 'click', '.cancel', @_hide_form

    @on 'ajax:success', '.remove', @_hide_form
    @on 'ajax:success', '.rate-edit', @_hide_form
    @on 'rate:change', @_change_score

    super()

  # handlers
  _toggle_list: (e) =>
    if @_is_persisted() && e.currentTarget.classList.contains('edit-trigger')
      if @form_html
        @_hide_form()
      else
        @_fetch_form()
    else
      super()

  _fetch_form: ->
    @_ajax_before()
    axios
      .get("/user_rates/#{@model.id}/edit")
      .then (response) =>
        @_ajax_complete()
        @_show_form(response.data)

  _show_form: (html) =>
    @form_html = html
    @_render()
    @$('.remove.bottom').addClass 'hidden'
    @$('.delete-button.top').removeClass 'hidden'

  _hide_form: =>
    @form_html = null
    @_render()

  _change_score: (e, score) =>
    @$('input[name="user_rate[score]"]').val score
    @$('form').submit()

  # functions
  _extended_html: ->
    @form_html || @_render_extended() if @_is_persisted()

  _render_extended: ->
    JST[EXTENDED_TEMPLATE](
      entry: @entry
      model: @model
      increment_url: @_increment_url()
      rate_html: JST[SCORE_TEMPLATE](score: @model.score)
    )

  _render: ->
    super()
    @$('.b-rate').rateable()

  _increment_url: ->
    if @_is_persisted()
      suffix = '?volumes' if @model.volumes != 0
      "/api/v2/user_rates/#{@model.id}/increment#{suffix || ''}"
