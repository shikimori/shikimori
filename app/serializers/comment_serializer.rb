class CommentSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :commentable_id, :commentable_type
  attributes :body, :html_body, :created_at, :updated_at
  attributes :is_offtopic, :is_summary
  attributes :can_be_edited?
  # attributes :viewed?

  has_one :user

  def html_body
    object.html_body.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def can_be_edited?
    view_context.can? :edit, object
  end
end
