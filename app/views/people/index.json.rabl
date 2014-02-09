object nil

node :content do
  render_to_string({
    partial: 'people/person',
    collection: @people,
    layout: false,
    formats: :html
  }) + (@add_postloader ? render_to_string({
    partial: 'site/postloader',
    locals: {
      url: send(@director.entry_search_url_builder, search: params[:search], page: @page+1, format: :json)
    },
    formats: :html
  }) : '')
end
