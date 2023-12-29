class Users::AssignSpecialRoles
  include Sidekiq::Worker
  sidekiq_options(
    lock: :until_executed,
    queue: :cpu_intensive
  )

  MIN_USER_RATES_IN_LIST = 30
  MIN_AI_TITLES_IN_LIST = 4

  def perform
    [Anime, Manga].each do |klass|
      process_klass klass
    end
  end

private

  def process_klass klass
    users_scope(klass).each do |user|
      user.roles << Types::User::Roles[:ai_genres]
      user.save!
    end
  end

  def users_scope klass
    User
      .where.not("roles && '{#{Types::User::Roles[:ai_genres]}}'")
      .joins(user_rates(klass))
      .where(user_rates(klass) => { target_type: klass.name })
      .where(user_rates(klass) => { target_id: ai_ids(klass) })
      .group(:id)
      .having("count(*) >= #{MIN_USER_RATES_IN_LIST}")
  end

  def ai_ids klass
    klass
      .where("genre_v2_ids && '{#{genres(klass).pluck(:id).join(',')}}'")
      .pluck(:id)
  end

  def genres klass
    "#{klass.name}GenresV2Repository"
      .constantize
      .instance
      .select(&:ai?)
  end

  def user_rates klass
    :"#{klass.name.downcase}_rates"
  end
end
