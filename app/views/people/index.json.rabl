object nil

node :content do
  render_to_string({
    partial: 'people/person_block',
    collection: @people,
    layout: false,
    formats: :html
  }) + (@add_postloader ? render_to_string({
    partial: 'blocks/postloader',
    locals: {
      url: send(@director.entry_search_url_builder, search: params[:search], page: @page+1, format: :json)
    },
    formats: :html
  }) : '')
end
