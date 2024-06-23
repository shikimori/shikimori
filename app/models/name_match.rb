# `phrase` should have `varchar_pattern_ops` index:
#   select * from pg_indexes where tablename = 'name_matches'
#     CREATE INDEX target_type_phrase_search_index ON name_matches USING btree (
#       target_type,
#       phrase varchar_pattern_ops
#     )
class NameMatch < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :anime,
    class_name: 'Anime',
    foreign_key: :target_id,
    optional: true
  belongs_to :manga,
    class_name: 'Manga',
    foreign_key: :target_id,
    optional: true

  validates :target_type, :phrase, presence: true
  validates :group, :priority,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  GROUPS = %i[
    predefined
    name
    alt alt2 alt3
    russian russian_alt
  ]
end
