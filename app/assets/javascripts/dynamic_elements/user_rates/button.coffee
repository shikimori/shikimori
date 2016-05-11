using 'DynamicElements'
class DynamicElements.UserRate extends View
  I18N_STATUS_KEY = 'activerecord.attributes.user_rate.statuses'

  initialize: ->
    @user_rate = @$root.data 'user_rate'
    @_render()

    # клик по раскрытию вариантов добавления в список
    @on 'click', '.trigger-arrow', @_toggle_list
    @on 'click', '.edit-trigger', @_toggle_list
    # клик по добавлению в свой список
    @on 'click', '.add-trigger', @_submit_status

    @on 'ajax:before', @_ajax_before
    @on 'ajax:ajax:error', @_ajax_complete
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
    @user_rate = user_rate
    @_render()

  _render: ->
    @html JST['templates/user_rates/user_rate'](@_render_params())

  _render_params: ->
    submit_url = if @user_rate.id
      "/api/v2/user_rates/#{@user_rate.id}"
    else
      '/api/v2/user_rates'

    user_rate: @user_rate
    user_id: USER_ID
    statuses: t("#{I18N_STATUS_KEY}.#{@user_rate.target_type.toLowerCase()}")
    form_url: submit_url
    form_method: if @user_rate.id then 'PATCH' else 'POST'
    destroy_url: "/api/v2/user_rates/#{@user_rate.id}" if @user_rate.id

  _new_user_rate: ->
    status: 'planned'
    target_id: @user_rate.target_id
    target_type: @user_rate.target_type
