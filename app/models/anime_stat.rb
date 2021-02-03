class AnimeStat < ApplicationRecord
  belongs_to :entry, polymorphic: true

  enumerize :entry_type,
    in: Types::AnimeStat::EntryType.values,
    predicates: true
end
