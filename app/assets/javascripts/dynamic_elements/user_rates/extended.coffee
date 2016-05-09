using 'DynamicElements.UserRates'
class DynamicElements.UserRates.Extended extends DynamicElements.UserRates.Button
  TEMPLATE = 'templates/user_rates/extended'

  initialize: ->
    @entry = @$root.data('entry')
    @form_html = null

    @on 'click', '.cancel', @_hide_form

    @on 'ajax:success', '.remove', @_hide_form
    @on 'ajax:success', '.rate-edit', @_hide_form

    super

  # handlers
  _toggle_list: (e) =>
    if @_is_persisted() && e.currentTarget.classList.contains('edit-trigger')
      if @form_html
        @_hide_form()
      else
        @_fetch_form()
    else
      super

  _fetch_form: ->
    @_ajax_before()
    $.get("/user_rates/#{@user_rate.id}/edit")
      .complete(@_ajax_complete)
      .success(@_show_form)

  _show_form: (html) =>
    @form_html = html
    @_render()

  _hide_form: =>
    @form_html = null
    @_render()

  # functions
  _extended_html: ->
    @form_html || @_render_extended() if @_is_persisted()

  _render_extended: ->
    JST[TEMPLATE](
      entry: @entry
      user_rate: @user_rate
      increment_url: "/api/v2/user_rates/#{@user_rate.id}/increment" if @_is_persisted()
    )
