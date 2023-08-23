module Types::Concerns::DescriptionFields
  extend ActiveSupport::Concern

  included do |_klass|
    field :description, String
    def description
      decorated_object.description.text
    end
    field :description_html, String
    def description_html
      decorated_object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
    end
    field :description_source, String
    def description_source
      decorated_object.description.source
    end
  end
end
