class ForumSerializer < ActiveModel::Serializer
  attributes :id, :position, :name, :permalink, :url

  def url
    forum_path object
  end
end
