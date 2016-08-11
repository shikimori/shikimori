using 'DynamicElements.UserRates'
class DynamicElements.UserRates.Button extends View
  TEMPLATE = 'templates/user_rates/button'
  I18N_STATUS_KEY = 'activerecord.attributes.user_rate.statuses'

  initialize: ->
    # data attribute is set in UserRates.Tracker
    @entry_data = @$root.data 'entry_data'
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

    (=>
      if @$('.b-add_to_list').hasClass 'expanded'
        @$('.expanded-options').css height: @$('.expanded-options').data('height')
      else
        @$('.expanded-options').css height: 0
    ).delay()

  _submit_status: (e) =>
    $form = $(e.target).closest('form')
    $form.find('input[name="user_rate[status]"]').val $(e.currentTarget).data('status')
    $form.submit()

  _ajax_before: =>
    if USER_SIGNED_IN
      @$root.addClass 'ajax_request'
    else
      $.info t(DynamicElements.AuthorizedAction.I18N_KEY)
      false

  _ajax_complete: =>
    @$root.removeClass 'ajax_request'

  _ajax_success: (e, user_rate) =>
    UserRates.Tracker.update user_rate || @_new_user_rate()
    @_ajax_complete()

  # functions
  update: (user_rate) ->
    @entry_data = user_rate
    @_render()

  _is_persisted: ->
    !!@entry_data.id

  _render: ->
    @html JST[TEMPLATE](@_render_params())

  _render_params: ->
    submit_url = if @_is_persisted()
      "/api/v2/user_rates/#{@entry_data.id}"
    else
      '/api/v2/user_rates'

    user_rate: @entry_data
    user_id: USER_ID
    statuses: t("#{I18N_STATUS_KEY}.#{@entry_data.target_type.toLowerCase()}")
    form_url: submit_url
    form_method: if @_is_persisted() then 'PATCH' else 'POST'
    destroy_url: "/api/v2/user_rates/#{@entry_data.id}" if @_is_persisted()
    extended_html: @_extended_html()

  _new_user_rate: ->
    status: 'planned'
    target_id: @entry_data.target_id
    target_type: @entry_data.target_type

  # must be redefined in inherited class
  _extended_html: ->
