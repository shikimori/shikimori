object nil

node :content do
  render_to_string(partial: 'users/user', collection: @users, layout: false, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'site/postloader_new', locals: { filter: 'b-user', url: users_path(page: @page+1, search: params[:search]) }, formats: :html) :
      '')
end
