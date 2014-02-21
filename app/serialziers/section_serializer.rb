class SectionSerializer < ActiveModel::Serializer
  attributes :id, :position, :name, :permalink, :url

  def url
    section_path object
  end
end
