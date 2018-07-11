class BigDataCache < ApplicationRecord
  serialize :value

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true

  def self.write
  end

  def self.read key
    where(expires_at: nil)
      .or(where('expires_at > ?', Time.zone.now))
      .find_by(key: key)
      &.value
  end

  def self.fetch
  end
end
