class CollectionLink < ApplicationRecord
  belongs_to :collection,
    touch: true,
    counter_cache: :links_count
  belongs_to :linked, polymorphic: true

  Types::Collection::Kind.values.each do |kind| # rubocop:disable Style/HashEachMethods
    belongs_to kind,
      inverse_of: :collection_links,
      foreign_key: :linked_id,
      class_name: kind.to_s.capitalize, # rubocop:disable Rails/ReflectionClassName
      touch: true,
      optional: true
  end

  validates :collection, :linked, presence: true
  validates :linked_id, uniqueness: { scope: %i[collection_id group] }

  enumerize :linked_type,
    in: Types::Collection::Kind.values.map(&:to_s).map(&:classify),
    predicates: true

  validate :not_censored

private

  def not_censored
    if linked.respond_to?(:censored?) && linked.censored?
      errors.add :linked, :censored
    end
  end
end
