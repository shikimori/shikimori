module Types::JsonbActiveModel
  extend ActiveSupport::Concern

  included do |klass|
    klass.send :extend, ActiveModel::Naming
    klass.send :extend, ActiveModel::Translation

    klass.class_eval do
      klass.const_set :MODEL_NAME, ActiveModel::Name.new(
        self,
        nil,
        name.split('::').last.underscore
      )

      def self.model_name
        self::MODEL_NAME
      end
    end
  end

  def to_model
    self
  end

  # need for cases when ShallowAttribute field is initialized by other
  # nested shallow attribute object
  def coerce value, _options = {}
    self.attributes =
      if value.instance_of?(self.class)
        value.attributes.clone
      else
        value
      end

    self
  end

  # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/type/json.rb
  class_methods do
    def type
      # self
      name.underscore.to_sym
    end

    def deserialize value
      cast JSON.parse(value, symbolize_names: true) if value
    end

    def serialize value
      ActiveSupport::JSON.encode value.to_hash if value
    end

    def changed_in_place? raw_old_value, new_value
      deserialize(raw_old_value) != new_value
    end

    def assert_valid_value _value
    end

    def force_equality? _value
      false
    end

    def cast value
      if value.is_a? self
        value
      elsif value
        new value
      end
    # rescue ArgumentError => e
    #   if e.message == 'invalid value for Float(): ""'
    #     new nil
    #   else
    #     raise
    #   end
    end

    def changed? original_value, value, _value_before_type_cast
      original_value != value
    end

    def binary?
      false
    end

    # for rails < 5.0
    def type_cast_from_database value
      deserialize value
    end

    def type_cast_from_user value
      cast value
    end

    def type_cast_for_database value
      serialize value
    end
  end
end
