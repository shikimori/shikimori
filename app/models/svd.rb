class Svd < ActiveRecord::Base
  Full = 'full'
  Partial = 'partial'

  serialize :lsa
  serialize :entry_ids
  serialize :user_ids

  attr_accessible :scale, :kind

  validates :lsa, presence: true
  validates :entry_ids, presence: true
  validates :user_ids, presence: true
  validates :scale, presence: true, inclusion: { in: [Full, Partial] }
  validates :kind, presence: true, inclusion: { in: [Anime.name, Manga.name] }

  class << self
    def full
      where(scale: Full, kind: Anime.name).last
    end

    def partial
      where(scale: Partial, kind: Anime.name).last
    end

    def generate!(scale)
      new(scale: scale, kind: Anime.name).send :calculate!
    end
  end

  def rank(rates)
    scores_vector = Array.new(entry_ids.size, 0)

    rates.each do |target_id, score|
      entry_index = entry_indexes[target_id]
      scores_vector[entry_index] = score if entry_index
    end

    ranks = lsa.classify_vector scores_vector
    kimilar_users = ranks.each_with_object({}) {|(index,similarity),memo| memo[user_ids[index]] = similarity }
  end

private
  # расчёт SVD
  def calculate!
    self.user_ids, self.entry_ids = prepare_ids self.scale
    rates = prepare_rates user_ids, entry_ids

    data_matrix = prepare_matrix rates, user_indexes, entry_indexes
    #return data_matrix, user_indexes, entry_indexes

    # вычисляем SVD
    self.lsa = LSA.new data_matrix
    self.save!
  end

  # подготовка данных для SVD матрицы
  def prepare_ids(scale)
    if scale == Full
      entry_ids = klass.where do
        (kind != 'Special')
        (kind != 'Music')
      end
      user_ids = UserRate
          .where(target_type: klass.name, target_id: entry_ids)
          .where(Recommendations::RatesFetcher.rate_query)
          .joins(Recommendations::RatesFetcher.join_query Anime)
          .pluck(:user_id)
          .uniq

      entry_ids = UserRate
          .where(target_type: klass.name, user_id: user_ids, target_id: entry_ids)
          .where(Recommendations::RatesFetcher.rate_query)
          .joins(Recommendations::RatesFetcher.join_query Anime)
          .pluck(:target_id)
          .uniq

    else
      entry_ids = klass.where do
        (score >= 6) &
        (kind != 'Special') &
        (kind != 'Music') &
        (duration > 5) &
        (censored.eq(0)) &
        (status != 'Not yet aired') &
        (
          (aired_at > '1995-01-01') |
          ((score > 7.5) & (aired_at > '1990-01-01')) |
          (score > 8.0) | ((score > 7.7) & (kind.eq('Movie')))
        )
      end.pluck(:id)

      user_ids = UserRate
          .where(target_type: klass.name, target_id: entry_ids)
          .where(Recommendations::RatesFetcher.rate_query)
          .joins(Recommendations::RatesFetcher.join_query(klass))
          .group(:user_id)
          .having("count(*) > 100 and count(*) < 1000")
          .pluck(:user_id)
          .uniq

      entry_ids = UserRate
          .where(target_type: klass.name, user_id: user_ids, target_id: entry_ids)
          .where(Recommendations::RatesFetcher.rate_query)
          .joins(Recommendations::RatesFetcher.join_query(klass))
          .pluck(:target_id)
          .uniq

      entry_ids = UserRate
          .where(target_type: klass.name, user_id: user_ids, target_id: entry_ids)
          .where(Recommendations::RatesFetcher.rate_query)
          .joins(Recommendations::RatesFetcher.join_query(klass))
          .group(:target_id)
          .having('count(*) > 4')
          .pluck(:target_id)
          .uniq
    end

    [user_ids, entry_ids]
  end

  # оценки конкретных пользователей по конкретным аниме
  def prepare_rates(user_ids, entry_ids)
    fetcher = Recommendations::RatesFetcher.new(klass)
    fetcher.by_user = false
    fetcher.with_deletion = false
    fetcher.user_ids = user_ids
    fetcher.target_ids = entry_ids
    fetcher.fetch Recommendations::Normalizations::MeanCentering.new
    #fetcher.fetch Recommendations::Normalizations::None.new
  end

  # заполнение SVD матрицы
  def prepare_matrix(rates, user_indexes, entry_indexes)
    data_matrix = SVDMatrix.new user_indexes.size, entry_indexes.size
    empty_row = Array.new user_indexes.size, 0

    entry_indexes.each do |entry_id,entry_index|
      row = empty_row.clone

      debugger unless rates[entry_id]
      rates[entry_id].each do |user_id, score|
        user_index = user_indexes[user_id]
        debugger unless user_index
        raise 'nil index' unless user_index # на время отладки
        row[user_index] = score
      end
      raise 'row overflow' if row.size > user_indexes.size # на время отладки

      data_matrix.set_row entry_index, row
    end

    data_matrix
  end

  def klass
    @klass ||= kind.constantize
  end

  def user_indexes
    @user_indexes ||= user_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }
  end

  def entry_indexes
    @entry_indexes ||= entry_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }
  end
end
