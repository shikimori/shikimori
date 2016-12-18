class ExternalLink < ActiveRecord::Base
  belongs_to :entry, polymorphic: true
  validates :entry, :source, :url, presence: true

  # sources are external link types from MAL
  enumerize :source,
    in: Types::ExternalLink::Source.values,
    predicates: { prefix: true }
end
