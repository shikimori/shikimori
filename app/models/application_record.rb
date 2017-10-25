class ApplicationRecord < ActiveRecord::Base
  extend Enumerize

  self.abstract_class = true

  class << self
    # fixes where(id: 11111111111111111111111111) - bigint
    def where *args
      if args.size == 1 && args[0].is_a?(Hash) && args[0].key?(:id)
        super(id: Array(args[0][:id]).map { |id| _fix_id(id) }.compact)
      else
        super
      end
    end

    def _fix_id id
      id_in_int =
        if id.is_a?(String)
          return nil unless id.match?(/^\d$/)
          Integer(id)
        else
          id
        end

      (1..2_147_483_647).cover?(id_in_int) ? id_in_int : nil
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

    def sanitize data
      connection.quote data
    end
  end
end
