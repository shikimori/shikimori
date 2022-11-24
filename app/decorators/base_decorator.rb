class BaseDecorator < Draper::Decorator
  include Translation

  delegate_all

  def self.inherited target
    target.send :prepend, ActiveCacher.instance
    super target
  end

  def page
    # do not use h.page because of conflicts with sidekiq module (fails on /about and /ongoings)
    if Rails.env.test?
      h.page
    else
      h.controller.instance_variable_get(:@page)
    end
  end

  # without this method active_model_serializes 0.10.4
  # does not serialize decorated objects
  def serializer_class
    if object.respond_to? :serializer_class
      object.serializer_class
    else
      "#{object.class.name}Serializer".constantize
    end
  end
end
