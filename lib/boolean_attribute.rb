module BooleanAttribute
  def boolean_attribute attribute_name
    self.send :define_method, "#{attribute_name}?" do
      send "is_#{attribute_name}"
    end
  end

  def boolean_attributes *attribute_names
    attribute_names.each do |attribute_name|
      boolean_attribute attribute_name
    end
  end
end
