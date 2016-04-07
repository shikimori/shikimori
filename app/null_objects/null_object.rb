# frozen_string_literal: true

class NullObject
  prepend ActiveCacher.instance
  instance_cache :base_object

  def respond_to_missing? method_name, include_private = false
    base_object.respond_to? method_name || super
  end

  def method_missing method_name, *args, &block
    return false if method_name.to_s.end_with?('?')
  end

private

  def base_object
    base_klass.new
  end
end
