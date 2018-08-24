import Topic from './topic'

export default class FullDialog extends Topic
  # handlers
  _before_comments_clickload: ->

  # private functions
  _update_comments_loader: (data) ->
    if data.postloader
      $new_comments_loader = $(data.postloader).process()
      @$comments_loader.replaceWith $new_comments_loader
      @$comments_loader = $new_comments_loader
    else
      @$comments_loader.remove()
      @$comments_loader = null
