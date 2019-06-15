class StyleSerializer < ActiveModel::Serializer
  attributes :id,
    :owner_id,
    :owner_type,
    :name,
    :css,
    :compiled_css,
    :created_at,
    :updated_at
end
