class Comments::Replies
  method_object :comment

  def call
    search_ids = Set.new [@comment.id]

    comments_scope
      .each do |comment|
        search_ids.clone.each do |id|
          next unless reply? comment.body, id

          search_ids << comment.id
        end
      end
      .select { |v| search_ids.include? v.id }
  end

private

  def comments_scope
    Comment
      .where('id > ?', @comment.id)
      .where(
        commentable_type: @comment.commentable_type,
        commentable_id: @comment.commentable_id
      )
      .order(:id)
      .limit(10_000)
  end

  def reply? body, comment_id
    body.include?("[comment=#{comment_id}]") ||
      body.include?("[comment=#{comment_id};") ||
      body.include?("[quote=c#{comment_id};") ||
      body.include?(">?c#{comment_id};")
  end
end
