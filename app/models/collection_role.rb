class CollectionRole < ApplicationRecord
  belongs_to :user
  belongs_to :collection, touch: true

  validates :user_id, uniqueness: { scope: :collection_id }
end
