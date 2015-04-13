module Translation
  extend ActiveSupport::Concern

  included do
    def t key, *args
      # raises exception if no translation found
      I18n.t! "#{self.class.name.underscore}.#{key}", *args
      # TODO yield block to accept extra options
    rescue
      # fallback to default helper if fuzzy search fails
      I18n.t key, *args
    end
  end
end
