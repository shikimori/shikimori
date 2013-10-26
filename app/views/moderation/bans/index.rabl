object nil

node :content do
  render_to_string(partial: 'moderation/bans/ban', collection: @bans, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader_new', locals: { url: page_moderation_bans_url(page: @page+1) }, formats: :html) :
      '')
end
