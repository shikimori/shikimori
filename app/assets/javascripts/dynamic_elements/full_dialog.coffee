import Topic from './topic'

export default class FullDialog extends Topic
  # handlers
  _before_comments_clickload: ->

  # private functions
  _update_comments_loader: (data) ->
    if data.postloader
      $new_comments_loader_wrapper = $(data.postloader).process()
      @$comments_loader_wrapper.replaceWith $new_comments_loader_wrapper
      @$comments_loader_wrapper = $new_comments_loader_wrapper
      @$comments_loader = @$comments_loader_wrapper.children('.comments-loader')
    else
      @$comments_loader_wrapper.remove()
      @$comments_loader_wrapper = null
      @$comments_loader = null
