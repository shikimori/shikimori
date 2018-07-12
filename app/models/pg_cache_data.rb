class PgCacheData < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true
end
