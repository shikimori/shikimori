jQuery ->
  $('#chapters').change (e) ->
    window.location = $("#chapters option:selected").val()
