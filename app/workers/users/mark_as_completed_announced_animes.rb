class Users::MarkAsCompletedAnnouncedAnimes
  include Sidekiq::Worker

  COMPLETED_ANNOUNCES_LIMIT = 3

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
      .each do |user|
        user.roles = user.roles.reject { |v| v == 'completed_announced_animes' }
        user.save!
      end
  end

  def assign_roles
    User.where(id: user_ids_scope).each do |user|
      user.roles << Types::User::Roles[:completed_announced_animes]
      user.save!
    end
  end

  def user_ids_scope
    UserRate
      .where(target_id: Anime.where(status: 'anons').select(:id))
      .where(target_type: 'Anime', status: 'completed')
      .group(:user_id)
      .having("count(*) >= #{COMPLETED_ANNOUNCES_LIMIT}")
      .select(:user_id)
  end
end
