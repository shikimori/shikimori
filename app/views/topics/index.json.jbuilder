json.content render(partial: 'topics/topic', collection: @topics, formats: :html)

if @add_postloader
  json.postloader render(partial: 'blocks/postloader', locals: { filter: 'topic', url: section_url(page: @page+1, section: @section[:permalink], linked: params[:linked]), next_url: section_url(page: @page+1, section: @section[:permalink]), prev_url: @page > 1 ? section_url(page: @page-1, section: @section[:permalink]) : nil }, formats: :html)
end
