object nil

node :content do
  render_to_string(partial: 'groups/group', collection: @groups, layout: false, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader', locals: { filter: 'index-item', url: page_clubs_path(page: @page+1) }, formats: :html) :
      '')
end
