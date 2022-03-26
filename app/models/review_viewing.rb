# TODO: delete it after https://github.com/shikimori/shikimori/pull/2360 is published
class ReviewViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed,
    class_name: 'Review',
    inverse_of: :viewings
end
