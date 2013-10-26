object @ban
attribute :id, :abuse_request_id, :comment_id

node :notice do |ban|
  I18n.t "messages.user_#{ban.warning? ? 'warned' : 'banned'}"
end

node :comment_html do |ban|
  render_to_string({
    partial: 'comments/comment',
    layout: false,
    object: ban.comment
  }) if ban.comment
end
