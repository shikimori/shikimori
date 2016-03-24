class CommentSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :commentable_id, :commentable_type
  attributes :body, :html_body, :created_at, :updated_at
  attributes :offtopic, :is_offtopic, :review, :is_summary
  attributes :viewed?, :can_be_edited?

  has_one :user

  # TODO remove in half a year (summary 2016)
  def review
    object.is_summary
  end

  # TODO remove in half a year (summary 2016)
  def offtopic
    object.is_offtopic
  end
end
