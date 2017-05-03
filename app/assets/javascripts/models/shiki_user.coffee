module.exports = class ShikiUser
  PUBLIC_FIELDS = [
    'is_moderator'
    'is_day_registered'
    'is_week_registered'
    'is_ignore_copyright'
    'is_comments_auto_collapsed'
    'is_comments_auto_loaded'
  ]

  constructor: (@data) ->
    @id = @data.id
    @is_signed_in = !!@id
    PUBLIC_FIELDS.forEach (field) =>
      @[field] = @data[field]

  topic_ignored: (topic_id) ->
    @data.ignored_topics.indexOf(topic_id) != -1

  user_ignored: (user_id) ->
    @data.ignored_users.indexOf(user_id) != -1

  ignore_topic: (topic_id) ->
    @data.ignored_topics.push parseInt(topic_id)

  unignore_topic: (topic_id) ->
    @data.ignored_topics.remove parseInt(topic_id)
