module DslAttribute
  def self.included target
    raise 'do not include DslAttribute - extend it instead'
  end

  def dsl_attribute attribute_name, default_value = nil
    instance_variable_name = "@#{attribute_name.to_s.sub('?', '')}"
    constant_name = attribute_name.to_s.sub('?', '').upcase

    define_singleton_method attribute_name do |value|
      instance_variable_set instance_variable_name, value
      const_set constant_name, value
    end

    define_method attribute_name do
      self.class.instance_variable_get(instance_variable_name) ||
        (self.class.const_defined?(constant_name) ? self.class.const_get(constant_name) : nil) ||
        default_value
    end

    if default_value
      send attribute_name, default_value
    end
  end
end
