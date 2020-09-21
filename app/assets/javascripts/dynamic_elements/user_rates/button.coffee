import delay from 'delay'
import { flash } from 'shiki-utils'

import UserRatesTracker from 'services/user_rates/tracker'
import View from 'views/application/view'
import JST from 'helpers/jst'

import * as AuthorizedAction from '../authorized_action'

export default class UserRateButton extends View
  TEMPLATE = 'user_rates/button'
  I18N_KEY = 'activerecord.attributes.user_rate.statuses'

  initialize: ->
    # data attribute is set in UserRatesTracker
    @model = @$root.data 'model'
    @_render()

    # delegated handlers because @_render can be called multiple times
    @on 'click', '.trigger-arrow', @_toggle_list
    @on 'click', '.edit-trigger', @_toggle_list

    @on 'click', '.add-trigger', @_submit_status

    @on 'ajax:before', @_ajax_before
    @on 'ajax:error', @_ajax_complete
    @on 'ajax:success', @_ajax_success

  # handlers
  _toggle_list: =>
    @$('.b-add_to_list').toggleClass('expanded')

    unless @$('.expanded-options').data 'height'
      @$('.expanded-options')
        .data(height: @$('.expanded-options').height())
        .css(height: 0)
        .show()

    delay().then =>
      if @$('.b-add_to_list').hasClass 'expanded'
        @$('.expanded-options').css height: @$('.expanded-options').data('height')
      else
        @$('.expanded-options').css height: 0

  _submit_status: (e) =>
    $form = $(e.target).closest('form')
    $form.find('input[name="user_rate[status]"]').val $(e.currentTarget).data('status')
    $form.submit()

  _ajax_before: =>
    if window.SHIKI_USER.isSignedIn
      @$root.addClass 'b-ajax'
    else
      flash.info I18n.t("#{AuthorizedAction.I18N_KEY}.register_to_complete_action")
      false

  _ajax_complete: =>
    @$root.removeClass 'b-ajax'

  _ajax_success: (e, model) =>
    UserRatesTracker.update model || @_new_user_rate()
    @_ajax_complete()

  # functions
  update: (@model) ->
    @_render()

  _is_persisted: ->
    !!@model.id

  _render: ->
    @html(JST[TEMPLATE](@_render_params())).process()

  _render_params: ->
    submit_url = if @_is_persisted()
      "/api/v2/user_rates/#{@model.id}"
    else
      '/api/v2/user_rates'

    model: @model
    user_id: window.SHIKI_USER.id
    statuses: I18n.t("#{I18N_KEY}.#{@model.target_type.toLowerCase()}")
    form_url: submit_url
    form_method: if @_is_persisted() then 'PATCH' else 'POST'
    destroy_url: "/api/v2/user_rates/#{@model.id}" if @_is_persisted()
    extended_html: @_extended_html()

  _new_user_rate: ->
    status: 'planned'
    target_id: @model.target_id
    target_type: @model.target_type

  # must be redefined in inherited class
  _extended_html: ->
