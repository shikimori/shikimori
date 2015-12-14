json.content render(partial: 'versions/version', collection: @resource.versions_page.first, formats: :html)

if @resource.versions_page.second
  json.postloader render('blocks/postloader', next_url: @resource.next_versions_page)
end
