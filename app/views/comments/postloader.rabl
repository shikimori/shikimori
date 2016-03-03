object nil

node :content do
  render_to_string(partial: 'comments/comment', collection: @comments, formats: :html) +
    (@add_postloader ?
      render_to_string(partial: 'blocks/postloader', locals: { filter: 'comment', next_url: model_comments_path(commentable_type: params[:commentable_type], commentable_id: params[:commentable_id], offset: @offset+@limit, limit: @limit, review: params[:review]) }, formats: :html) :
      '')
end
