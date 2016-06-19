# frozen_string_literal: true

class Club::Update < ServiceObjectBase
  pattr_initialize :model, :kick_ids, :params

  def call
    kick_users
    update_club

    model
  end

private

  def kick_users
    users_to_kick = User.where id: (kick_ids || [])
    users_to_kick.each { |user| model.leave user }
  end

  # rubocop:disable MethodLength
  def update_club
    exceptions = [PG::UniqueViolation, ActiveRecord::RecordNotUnique]

    Retryable.retryable tries: 2, on: exceptions, sleep: 1 do
      Club.transaction do
        model.animes = []
        model.mangas = []
        model.characters = []
        model.banned_users = []

        model.member_roles.where(role: :admin).destroy_all
        model.member_roles.where(user_id: params[:admin_ids]).destroy_all

        model.update params
      end
    end
  end
  # rubocop:enable MethodLength
end
