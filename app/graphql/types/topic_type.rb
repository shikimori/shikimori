class Types::TopicType < Types::BaseObject
  field :id, GraphQL::Types::ID
  field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  field :title, String, null: false
  def title
    view_object.topic_title
  end

  field :type, String, null: false
  field :body, String, null: false
  field :html_body, String, null: false
  field :url, String, null: false
  delegate :html_body, :url, to: :view_object

  field :tags, [String], null: false
  field :comments_count, Integer, null: false

private

  def view_object
    @view_object ||= Topics::TopicViewFactory
      .new(false, false)
      .build(object)
  end
end
