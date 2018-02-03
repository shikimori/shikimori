module BreadcrumbsConcern
  extend ActiveSupport::Concern

  included do
    class_attribute :breadcrumbs
    before_action { self.class.breadcrumbs = {} }

    helper_method :page_breadcrumbs
  end

  def breadcrumb title, url
    self.class.breadcrumbs[title] = url
  end

  def no_breadcrumbs
    self.class.breadcrumbs = {}
  end

  def page_breadcrumbs
    @page_breadcrumbs ||= self.class.breadcrumbs
      .each_with_object({}) do |(title, url_builder), memo|
        memo[title] =
          if url_builder.is_a?(Symbol)
            send url_builder
          else
            url_builder
          end
      end
  end

  class_methods do
    def breadcrumb title, url
      before_action { breadcrumbs[title] = url }
    end
  end
end
