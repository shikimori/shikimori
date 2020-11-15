class ApplicationRecord < ActiveRecord::Base
  extend Enumerize

  self.abstract_class = true

  # https://github.com/rails/rails/issues/3508#issuecomment-592744109
  def serializable_hash(options = nil)
    return super(options) unless has_attribute?(self.class.inheritance_column)

    options = options.try(:dup) || {}

    options[:methods]  = Array(options[:methods]).map(&:to_s)
    options[:methods] |= Array(self.class.inheritance_column)

    super(options)
  end

  class << self
    # for large batches sql must be ordered by id!!!
    def fetch_raw_data sql, batch_size
      offset = 0

      begin
        batch = ActiveRecord::Base.connection.select_all <<-SQL.squish
          #{sql}
          LIMIT #{batch_size}
          OFFSET #{offset}
        SQL
        batch.each do |row|
          yield row
        end
        offset += batch_size
      end until batch.empty? # rubocop:disable Loop
    end

    def fix_id id
      return id if id.is_a?(String) && !id.match?(/\A\d+/)

      int_id = id.is_a?(String) ? Integer(id) : id
      (0..2_147_483_647).cover?(int_id) ? int_id : nil
    end

    # fixes .where(id: 11111111111111111111111111) - bigint
    # https://github.com/rails/rails/issues/20428
    def where(*args)
      id_key = args.one? && args[0].is_a?(Hash) &&
        args[0].one? && args[0].key?(:id)

      if id_key && _fixable_ids?(args[0][:id])
        super(id: _fix_ids(args[0][:id]))
      else
        super
      end
    end

    def _fixable_ids? ids
      ids.is_a?(String) || ids.is_a?(Integer) || ids.is_a?(Array)
    end

    def _fix_ids ids
      if ids.is_a? Array
        ids.map { |id| fix_id(id) }.compact
      else
        fix_id ids
      end
    end

    def boolean_attribute attribute_name
      define_method "#{attribute_name}?" do
        send "is_#{attribute_name}"
      end
    end

    def boolean_attributes *attribute_names
      attribute_names.each do |attribute_name|
        boolean_attribute attribute_name
      end
    end

    def wo_timestamp
      old = record_timestamps
      self.record_timestamps = false
      begin
        yield
      ensure
        self.record_timestamps = old
      end
    end

    def sanitize data, is_double_quotes = false
      # http://shikimori.local/animes/page/30?type=1%00%EF%BF%BD%EF%BF%BD%EF%BF%BD%EF%BF%BD%252527%252522
      data = data.delete("\u0000") if data.is_a? String

      if is_double_quotes
        connection.quote(data).gsub('"', '\\"').gsub(/(?>(?<!')'(?!'))/, '"')
      else
        connection.quote data
      end
    end
  end
end
