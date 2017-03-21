class ExternalLink < ApplicationRecord
  belongs_to :entry, polymorphic: true, touch: true
  validates :entry, :source, :kind, :url, presence: true

  enumerize :kind,
    in: Types::ExternalLink::Kind.values,
    predicates: { prefix: true }

  enumerize :source,
    in: Types::ExternalLink::Source.values,
    predicates: { prefix: true }
end
