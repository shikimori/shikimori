#= require_tree ../core/.
#= require_tree .

jQuery ->
  $("[title]").tooltip({ delay: 300, placement: 'bottom' })
