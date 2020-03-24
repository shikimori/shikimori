class ViewObjectBase
  include Draper::ViewHelpers
  include Translation

  prepend ActiveCacher.instance
  extend DslAttribute

  dsl_attribute :per_page_limit

  def page
    # do not use h.page because of conflicts with sidekiq
    h.controller.instance_variable_get(:'@page')
  end

  def read_attribute_for_serialization attribute
    send attribute
  end
end
