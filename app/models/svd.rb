class Svd < ActiveRecord::Base
  extend Enumerize

  serialize :lsa
  serialize :entry_ids
  serialize :user_ids

  validates :lsa, presence: true
  validates :entry_ids, presence: true
  validates :user_ids, presence: true
  #validates :scale, presence: true, inclusion: { in: [Full, Partial] }
  #validates :kind, presence: true, inclusion: { in: [Anime.name, Manga.name] }

  enumerize :scale, in: [:full, :partial], predicates: true
  enumerize :kind, in: [:anime], predicates: true
  enumerize :normalization, in: [:none, :mean_centering, :z_score], predicates: { prefix: true }

  def rank rates
    scores_vector = Array.new(entry_ids.size, 0)

    rates.each do |target_id, score|
      entry_index = entry_indexes[target_id]
      scores_vector[entry_index] = score if entry_index
    end

    lsa
      .classify_vector(scores_vector)
      .each_with_object({}) do |(index,similarity),memo|
        memo[user_ids[index]] = similarity
      end
  end

  def normalizer
    "Recommendations::Normalizations::#{normalization.classify}".constantize.new
  end

  def klass
    kind.classify.constantize
  end

  def user_indexes
    @user_indexes ||= user_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }
  end

  def entry_indexes
    @entry_indexes ||= entry_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }
  end

end
