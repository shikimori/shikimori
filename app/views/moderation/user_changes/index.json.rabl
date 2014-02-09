object nil

node :content do
  render_to_string(partial: 'site/editor_changes', locals: { changes: @processed, moderation: true }, formats: :html, layout: false) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader', locals: { url: moderation_users_changes_url(page: @page+1, format: :json) }, formats: :html, layout: false) :
      '')
end
