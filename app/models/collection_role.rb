class CollectionRole < ApplicationRecord
  belongs_to :user
  belongs_to :collection, touch: true
end
