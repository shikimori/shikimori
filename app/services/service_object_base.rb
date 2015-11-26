class ServiceObjectBase
  extend DslAttribute

  def self.call *args
    new(*args).call
  end
end
