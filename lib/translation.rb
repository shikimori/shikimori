# NOTE use ActionView::Helpers::TranslationHelper#translate to translate views
module Translation
  extend ActiveSupport::Concern

  included do
    def i18n_t key, options = {}
      yield options if block_given?
      # raises exception if no translation found
      I18n.t! "#{self.class.name.underscore}.#{key}", options
    # TODO specific exception
    #rescue
      ## fallback to default helper if fuzzy search fails
      #I18n.t key, options
    end

    def i18n_i key, count = 1, ru_case = :subjective
      if I18n.locale == :en
        I18n.t "inflections.#{key}", count: count,
          default: key.pluralize(count)
      else
        I18n.t "inflections.#{key}.#{ru_case}", count: count,
          default: "inflections.#{key}.default".to_sym
      end
    end
  end
end
