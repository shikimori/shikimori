json.content render(partial: 'messages/message', collection: @collection, formats: :html)

if @add_postloader
  json.postloader render('dialogs/postloader', url: show_profile_dialog_url(@dialog.user, @dialog.target_user.to_param(true), page: @page+1))
end
