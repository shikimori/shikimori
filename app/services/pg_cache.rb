class PgCache
  FIELD = {
    YAML => :value,
    MessagePack => :blob
  }

  class << self
    def write key, value, expires_in: nil, serializer: YAML
      key = stringify_key key
      Rails.logger.info "PgCache write: #{key} serializer: #{serializer}"

      ActiveRecord::Base.logger.silence do
        pg_cache_data = PgCacheData.new(
          key:,
          expires_at: expires_in&.from_now,
          FIELD[serializer] => serializer.dump(value)
        )
        PgCacheData.import [pg_cache_data], on_duplicate_key_update: {
          conflict_target: [:key], columns: [:expires_at, FIELD[serializer]]
        }
      end

      value
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      value
    end

    def read key, serializer: YAML
      key = stringify_key key
      Rails.logger.info "PgCache read: #{key} serializer: #{serializer}"

      PgCacheData.fetch_raw_data(
        PgCacheData.where(expires_at: nil)
          .or(PgCacheData.where('expires_at > ?', Time.zone.now))
          .where(key:)
          .select(FIELD[serializer])
          .to_sql,
        1
      ) { |entry| return serializer.pg_load(entry[FIELD[serializer].to_s]) }
    end

    def fetch key, expires_in: nil, serializer: YAML
      key = stringify_key key
      data = read(key, serializer:)

      if data.nil?
        Rails.logger.info "PgCache generate: #{key} serializer: #{serializer}"
        data = yield
        write key, data, expires_in:, serializer:
      end

      data
    end

    def delete key
      key = stringify_key key

      PgCacheData.where(key:).delete_all
    end

    def stringify_key key
      if key.is_a? String
        key

      elsif key.is_a? Array
        key.join '_'

      else
        key.to_s
      end
    end
  end
end
