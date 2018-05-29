using 'DynamicElements'
class DynamicElements.Tabs extends ShikiView
  initialize: ->
    @$tabs = @$('[data-tab]')
    @$tab_switches = @$('[data-tab-switch]')

    @$tab_switches.on 'click', @_switch_tab

  _switch_tab: (e) =>
    tab_index = @$tab_switches.toArray().indexOf(e.currentTarget)

    @$tab_switches.removeClass('active')
    e.currentTarget.classList.add 'active'

    @$tabs.addClass('hidden')
    @$tabs[tab_index].classList.remove 'hidden'
