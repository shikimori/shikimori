class SectionSerializer < ActiveModel::Serializer
  attributes :id, :position, :name, :permalink, :url

  def url
    section_url object
  end
end
