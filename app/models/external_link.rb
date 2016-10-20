class ExternalLink < ActiveRecord::Base
  belongs_to :entry, polymorphic: true
  validates :entry, :source, :url, presence: true

  enumerize :source,
    in: %i(official_site anime_db anime_news_network wikipedia),
    predicates: { prefix: true }
end
