#= require_tree ../core/.
#= require ../vendor/underscore
#= require_tree ../jquery/.
#= require ../lib/rails_ujs_modified
#= require_tree .

jQuery ->
  $("[title]").tooltip delay: 300, placement: 'bottom'
