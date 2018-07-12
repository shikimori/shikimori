class PgCache
  class << self
    def write key, value, expires_in: nil # rubocop:disable MethodLength
      key = stringify_key key

      PgCacheData.transaction do
        PgCache.delete key

        ActiveRecord::Base.logger.silence do
          Rails.logger.info "PgCache write: #{key}"
          PgCacheData.create!(
            key: key,
            expires_at: expires_in&.from_now,
            value: YAML.dump(value)
          )
        end
      end

      value
    end

    def read key
      key = stringify_key key
      Rails.logger.info "PgCache read: #{key}"

      PgCacheData.fetch_raw_data(
        PgCacheData.where(expires_at: nil)
          .or(PgCacheData.where('expires_at > ?', Time.zone.now))
          .where(key: key)
          .select(:value)
          .to_sql,
        1
      ) { |entry| return YAML.load(entry['value']) } # rubocop:disable YAMLLoad
    end

    def fetch key, expires_in: nil
      key = stringify_key key
      data = read(key)

      if data.nil?
        Rails.logger.info "PgCache generate: #{key}"
        data = yield
        write key, data, expires_in: expires_in
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
