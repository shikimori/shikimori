module ActiveCacher
  @cloned = false

  def self.instance
    cloned = clone
    cloned.instance_variable_set '@cloned', true
    cloned
  end

  def self.prepended target
    raise "do not prepend ActiveCacher, prepend ActiveCacher.instance instead" unless @cloned

    cacher = self

    target.send :define_singleton_method, :rails_cache do |*methods|
      methods.each do |method|
        cacher.send :define_method, method do |*args|
          instance_variable_get("@#{method}") ||
            instance_variable_set("@#{method}", Rails.cache.fetch([cache_key_object, method], expires_in: 2.weeks) { prepare_for_cache(super *args) })
        end
      end
    end

    target.send :define_singleton_method, :instance_cache do |*methods|
      methods.each do |method|
        cacher.send :define_method, method do |*args|
          instance_variable_get("@#{method}") ||
            instance_variable_set("@#{method}", prepare_for_cache(super *args))
        end
      end
    end
  end

private
  def cache_key_object
    respond_to?(:object) ? object : self
  end

  def prepare_for_cache object
    object.kind_of?(ActiveRecord::Relation) ? object.to_a : object
  end
end
