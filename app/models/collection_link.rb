class CollectionLink < ApplicationRecord
  belongs_to :collection, touch: true
  belongs_to :linked, polymorphic: true

  Types::Collection::Kind.values.each do |kind|
    belongs_to kind, foreign_key: :linked_id, class_name: kind.capitalize
  end

  validates :collection, :linked, presence: true
  validates :linked_id, uniqueness: { scope: %i[collection_id group] }

  enumerize :linked_type,
    in: Types::Collection::Kind.values.map(&:to_s).map(&:classify),
    predicates: true
end
