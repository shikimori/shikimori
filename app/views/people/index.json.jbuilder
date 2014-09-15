json.content render @people

if @add_postloader
  render 'blocks/postloader', url: search_url(search: params[:search], page: @page+1)
end

