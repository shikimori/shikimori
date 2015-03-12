# клик по раскрытию вариантов добавления в список
$(document).on 'click', '.b-add_to_list .arrow', ->
  $root = $(@).closest('.b-add_to_list')

  $root.toggleClass 'expanded'

  $options = $('.expanded-options', $root)

  unless $options.data 'height'
    $options
      .data(height: $options.height())
      .css(height: 0)
      .show()

  (=>
    if $root.hasClass 'expanded'
      $options.css height: $options.data('height')
    else
      $options.css height: 0
  ).delay()
