class ServiceObjectBase
  extend DslAttribute

  def self.call *args
    new(*args).call
  end

  def self.fetch *args
    new(*args).fetch
  end

  def self.inherited target
    target.send :prepend, ActiveCacher.instance
  end
end
