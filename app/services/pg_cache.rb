class PgCache
  FIELD = {
    YAML => :value,
    MessagePack => :blob
  }

  class << self
    def write key, value, expires_in: nil, serializer: YAML
      key = stringify_key key
      Rails.logger.info "PgCache write: #{key} serializer: #{serializer}"

      PgCacheData.transaction do
        PgCache.delete key

        ActiveRecord::Base.logger.silence do
          PgCacheData.create!(
            key: key,
            expires_at: expires_in&.from_now,
            FIELD[serializer] => serializer.dump(value)
          )
        end
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
          .where(key: key)
          .select(FIELD[serializer])
          .to_sql,
        1
      ) { |entry| return serializer.pg_load(entry[FIELD[serializer].to_s]) }
    end

    def fetch key, expires_in: nil, serializer: YAML
      key = stringify_key key
      data = read key, serializer: serializer

      if data.nil?
        Rails.logger.info "PgCache generate: #{key} serializer: #{serializer}"
        data = yield
        write key, data, expires_in: expires_in, serializer: serializer
      end

      data
    end

    def delete key
      key = stringify_key key

      PgCacheData.where(key: key).delete_all
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
