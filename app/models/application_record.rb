class ApplicationRecord < ActiveRecord::Base
  extend Enumerize

  self.abstract_class = true

  class << self
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
