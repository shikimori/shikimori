class BigDataCache < ApplicationRecord
  serialize :value

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true

  # not really thread safe but I don't care
  def self.write key, value, expires_in: nil
    entry = find_or_initialize_by(key: key)

    entry.update!(
      expires_at: expires_in&.from_now,
      value: value
    )
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
