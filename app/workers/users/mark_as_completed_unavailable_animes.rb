class Users::MarkAsCompletedUnavailableAnimes
  include Sidekiq::Worker
  sidekiq_options(
    lock: :until_executed,
    lock_args: ->(args) { args.first },
    queue: :cpu_intensive
  )

  CONFIG_PATH = Rails.root.join('config/app/unavailable_animes.yml')

  COMPLETED_ANNOUNCES_LIMIT = 2
  COMPLETED_UNAVAILABLES_LIMIT = 2

  def perform
    User.transaction do
      cleanup_roles
      assign_roles
    end
  end

private

  def cleanup_roles
    User
      .where("roles && '{#{Types::User::Roles[:completed_announced_animes]}}'")
      .update_all(
        <<~SQL.squish
          updated_at = #{ApplicationRecord.sanitize Time.zone.now},
          roles = array_remove(roles, 'completed_announced_animes')
        SQL
      )
      # .each do |user|
      #   user.roles = user.roles.reject { |v| v == 'completed_announced_animes' }
      #   user.save!
      # end
  end

  def assign_roles
    User
      .where(id: user_ids_completed_announces_scope)
      .or(
        User.where(id: user_ids_completed_unavailables_scope)
      )
      .update_all(
        <<~SQL.squish
          updated_at = #{ApplicationRecord.sanitize Time.zone.now},
          roles = array_append(roles, 'completed_announced_animes')
        SQL
      )
      # .each do |user|
      #   user.roles << Types::User::Roles[:completed_announced_animes]
      #   user.save!
      # end
  end

  def user_ids_completed_announces_scope
    UserRate
      .where(target_id: Anime.where(status: 'anons').select(:id))
      .where(target_type: 'Anime', status: 'completed')
      .group(:user_id)
      .having("count(*) >= #{COMPLETED_ANNOUNCES_LIMIT}")
      .select(:user_id)
  end

  def user_ids_completed_unavailables_scope
    UserRate
      .where(target_id: unvailable_anime_ids)
      .where(target_type: 'Anime', status: 'completed')
      .group(:user_id)
      .having("count(*) >= #{COMPLETED_UNAVAILABLES_LIMIT}")
      .select(:user_id)
  end

  def unvailable_anime_ids
    @unvailable_anime_ids ||= YAML.load_file CONFIG_PATH
  end
end
