class @ShikiUser
  constructor: (@data) ->
    @id = @data.id
    @is_moderator = @data.is_moderator

  topic_ignored: (topic_id) ->
    @data.ignored_topics.indexOf(topic_id) != -1

  user_ignored: (user_id) ->
    @data.ignored_users.indexOf(user_id) != -1

  ignore_topic: (topic_id) ->
    @data.ignored_topics.push parseInt(topic_id)

  unignore_topic: (topic_id) ->
    @data.ignored_topics.remove parseInt(topic_id)
