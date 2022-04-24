module ShallowAttributes::InstanceMethods::CompareFix
  def ==(object)
    return false unless object.respond_to? :to_h
    to_h == object.to_h
  end
end

ShallowAttributes.send :prepend, ShallowAttributes::InstanceMethods::CompareFix
