class CollectionLink < ApplicationRecord
  belongs_to :collection, touch: true
  belongs_to :linked, polymorphic: true

  validates :collection, :linked, presence: true
  validates :linked_id, uniqueness: { scope: [:collection_id] }

  enumerize :linked_type, in: %i[Anime Manga Character Person], predicates: true
end
