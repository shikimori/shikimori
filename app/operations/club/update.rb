# frozen_string_literal: true

class Club::Update
  method_object :model, :kick_ids, :params, :section, :actor

  ALLOWED_EXCEPTIONS = [PG::UniqueViolation, ActiveRecord::RecordNotUnique]

  def call
    kick_users
    Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
      is_updated = update_club
      Changelog::LogUpdate.call @model, @actor if is_updated
    end

    @model
  end

private

  def kick_users
    users_to_kick = User.where id: (@kick_ids || [])
    users_to_kick.each { |user| @model.leave user }
  end

  def update_club
    Club.transaction do
      cleaup_links if links_page?
      cleaup_members if members_page?

      @model.update @params
    end
  end

  def cleaup_links
    [Anime, Manga, Ranobe, Character, Club, Collection].each do |klass|
      @model.links.where(linked_type: klass.name).delete_all
    end
    @model.touch # because links.delete_all wont update club's updated_at
  end

  def cleaup_members
    @model.banned_users = []
    @model.member_roles.where(role: :admin).update_all role: :member
    @model.member_roles.where(user_id: @params[:admin_ids]).destroy_all
  end

  def links_page?
    @section == 'links'
  end

  def members_page?
    @section == 'members'
  end
end
