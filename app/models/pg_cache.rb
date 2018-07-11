class PgCache < ApplicationRecord
  serialize :value

  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value, presence: true

  # it is not really thread safe but I don't care
  def self.write key, value, expires_in: nil
    entry = find_or_initialize_by(key: key)

    entry.update!(
      expires_at: expires_in&.from_now,
      value: value
    )

    value
  end

  def self.read key
    where(expires_at: nil)
      .or(where('expires_at > ?', Time.zone.now))
      .find_by(key: key)
      &.value
  end

  def self.fetch key, expires_in: nil
    read(key) || write(key, yield, expires_in: expires_in)
  end

  def self.delete key
    find_by(key: key)&.destroy!
  end
end
