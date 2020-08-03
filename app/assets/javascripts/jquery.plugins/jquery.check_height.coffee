import { animatedExpand } from 'helpers/animated'

$.fn.extend
  # options:
  #   max_height - высота блока, при превышении которой будет свёртка
  #   without_shade - добавлять ли тень
  #   collapsed_height - высота свёрнутого блока
  #   expand_html - html для блока "развернуть"
  checkHeight: (options = {}) ->
    max_height = options.max_height || 450
    without_shade =
      if options.without_shade?
        options.without_shade
      else
        false
    collapsed_height =
      options.collapsed_height || Math.round(max_height * 2.0 / 3)
    shade_html =
      if without_shade then '' else "<div class='shade'></div>"
    expand_html =
      if options.expand_html?
        options.expand_html
      else
        "<div class='expand'><span>#{I18n.t('frontend.dynamic_elements.check_height.expand')}</span></div>"

    @each ->
      $root = $(@)

      if $root.height() > max_height && !$root.hasClass('shortened')
        margin_bottom = parseInt $root.css('margin-bottom')
        html = "<div class='b-height_shortener' style='margin-bottom: #{margin_bottom}px'>#{shade_html}#{expand_html}</div>"

        $root
          .addClass('shortened')
          .css(height: collapsed_height)

        $(html)
          .insertAfter($root)
          .on 'click', (e) ->
            return if expand_html? && !expand_html

            $root.removeClass 'shortened'
            animatedExpand $root[0]

            $(e.currentTarget).remove()
