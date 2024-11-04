class Users::AssignSpecialRoles
  include Sidekiq::Worker
  sidekiq_options(
    lock: :until_executed,
    queue: :cpu_intensive
  )

  MIN_USER_RATES_IN_LIST = 30
  MIN_AI_TITLES_IN_LIST = 4

  MASS_REGISTRATION_INTERVAL = 1.month
  MASS_REGISTRATION_THRESHOLD = 3

  def perform finish_on
    [Anime, Manga].each do |klass|
      process_klass klass
    end

    process_mass_registrations Date.parse(finish_on)
  end

private

  def process_klass klass
    users_scope(klass)
      .update_all(
        <<~SQL.squish
          updated_at = #{ApplicationRecord.sanitize Time.zone.now},
          roles = array_append(roles, '#{Types::User::Roles[:ai_genres]}')
        SQL
      )
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
      .select { |genre| genre.ai? || genre.banned? }
  end

  def user_rates klass
    :"#{klass.name.downcase}_rates"
  end

  def process_mass_registrations finish_on
    mass_registartgions_users_scope(finish_on)
      .where(current_sign_in_ip: mass_registrations_ips(finish_on))
      .update_all "roles = roles || '{#{Types::User::Roles[:mass_registration]}}'"
  end

  def mass_registrations_ips finish_on
    mass_registartgions_users_scope(finish_on)
      .where(read_only_at: nil)
      .group_by(&:current_sign_in_ip)
      .select { |_ip, users| users.size >= MASS_REGISTRATION_THRESHOLD }
      .map(&:first)
  end

  def mass_registartgions_users_scope finish_on
    Users::Query
      .fetch
      .created_on(start_on(finish_on).to_s, Users::Query::ConditionType[:gte])
      .created_on(finish_on.to_s, Users::Query::ConditionType[:lte])
      .where.not("roles && '{#{Types::User::Roles[:mass_registration]}}'")
  end

  def start_on finish_on
    finish_on - MASS_REGISTRATION_INTERVAL
  end
end
