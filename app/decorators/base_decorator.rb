class BaseDecorator < Draper::Decorator
  include Translation

  delegate_all

  def self.inherited target
    target.send :prepend, ActiveCacher.instance
  end
end
