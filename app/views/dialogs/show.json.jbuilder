json.content render(
  partial: 'messages/message',
  collection: @collection, formats: :html
)

json.postloader render(
  'dialogs/postloader',
  next_url: show_profile_dialog_url(@dialog.user, @dialog.target_user.to_param, page: @page + 1)
) if @add_postloader
