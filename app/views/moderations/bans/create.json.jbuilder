json.id @resource.id
json.abuse_request_id @resource.abuse_request_id
json.comment_id @resource.comment_id

json.notice I18n.t "messages.user_#{@resource.warning? ? 'warned' : 'banned'}"

if @resource.comment
  json.html render(
    partial: 'comments/comment',
    object: @resource.comment,
    layout: false,
    formats: %i[html]
  )
end
