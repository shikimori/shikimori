class PgCacheData < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: false }

  def self.fetch_raw_data sql, batch_size, &block
    offset = 0

    begin
      batch = ActiveRecord::Base.connection.select_all <<-SQL
        #{sql}
        LIMIT #{batch_size}
        OFFSET #{offset}
      SQL

      batch.each(&block)

      offset += batch_size
    end until batch.empty? # rubocop:disable Lint/Loop
  end
end
