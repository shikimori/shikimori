(($) ->
  $.extend
    flash: (options) ->
      if "alert" of options
        toastr.error options.alert

      else if "info" of options
        toastr.info options.info

      else
        toastr.success options.notice
) jQuery
