object nil

node :content do
  render_to_string(partial: 'moderation/bans/ban', collection: @bans, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'blocks/postloader', locals: { url: page_moderation_bans_url(page: @page+1) }, formats: :html) :
      '')
end
