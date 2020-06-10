# replies to the comment
class Comments::Replies
  method_object :comment

  def call
    search_ids = Set.new [@comment.id]

    comments_scope
      .each do |comment|
        search_ids.clone.each do |id|
          next unless comment.body.include?("[comment=#{id}]") ||
              comment.body.include?("[quote=#{id};") ||
              comment.body.include?("[quote=c#{id};")

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
      .limit(10000)
  end
end
