json.id @resource.id
json.abuse_request_id @resource.abuse_request_id
json.comment_id @resource.comment_id if @resource.comment_id
json.topic_id @resource.topic_id if @resource.topic_id
json.review_id @resource.review_id if @resource.review_id

json.notice I18n.t "messages.user_#{@resource.warning? ? 'warned' : 'banned'}"

if @resource.comment
  json.html JsExports::Supervisor.instance.sweep(
    render(
      partial: 'comments/comment',
      layout: false,
      object: @resource.comment.decorate,
      formats: :html
    )
  )
elsif @resource.review
  json.html JsExports::Supervisor.instance.sweep(
    render(
      partial: 'reviews/review',
      locals: {
        review: @resource.review,
        is_show: true,
        is_buttons: true
      },
      formats: %i[html]
    )
  )
elsif @resource.topic
  json.content JsExports::Supervisor.instance.sweep(
    render(
      partial: 'topics/topic',
      locals: {
        topic_view: Topics::TopicViewFactory.new(false, false).build(@resource.topic)
      },
      formats: :html
    )
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
