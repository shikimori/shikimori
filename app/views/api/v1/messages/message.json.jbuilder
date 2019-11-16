json.id @resource.id
json.html render(
  partial: 'messages/message',
  object: @resource.decorate,
  formats: %i[html]
)
json.notice local_assigns[:notice]
