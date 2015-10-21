class GroupDecorator < DbEntryDecorator
  MENU_ENTRIES = 12

  rails_cache :all_members, :all_animes, :all_mangas, :all_characters, :all_images
  instance_cache :description, :animes, :mangas, :characters, :images, :comments, :banned

  def url
    h.club_url object
  end

  def image
    object.logo
  end

  def all_members
    @members ||= member_roles
      .includes(:user)
      .order(created_at: :desc)
      .map(&:user)
  end

  def user_role
    member_roles.find {|v| v.user_id == h.current_user.id }.try :role if h.user_signed_in?
  end

  def members
    all_members.take 12
  end

  def animes
    ApplyRatedEntries.new(h.current_user).call(all_animes)
  end

  def mangas
    ApplyRatedEntries.new(h.current_user).call(all_mangas)
  end

  def characters
    all_characters.map(&:decorate)
  end

  def menu_animes
    all_animes
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:ranked)
      .map(&:decorate)
  end

  def menu_mangas
    all_mangas
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:ranked)
      .map(&:decorate)
  end

  def menu_characters
    all_characters
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:name)
      .map(&:decorate)
  end

  def images limit = 999
    all_images.take limit
  end

  def show_comments?
    h.user_signed_in? || comments.any?
  end

  def new_invite
    invites.new(src: h.current_user)
  end

  ## для отображения топиков клуба на форуме
  #def topics
    #[]
  #end

  ## для отображения топиков клуба на форуме
  #def news
    #[]
  #end

  class << self
    def join_policy_options
      Group.join_policies.map do |policy_name, policy_id|
        [I18n.t("activerecord.attributes.group.join_policies.#{policy_name}"), policy_name]
      end
    end

    def comment_policy_options
      Group.comment_policies.map do |policy_name, policy_id|
        [I18n.t("activerecord.attributes.group.comment_policies.#{policy_name}"), policy_name]
      end
    end
  end

private

  def all_images
    return [] unless display_images?
    object
      .images
      .order(created_at: :desc)
  end

  def all_animes
    object.animes.order(:ranked).uniq(&:id)
  end

  def all_mangas
    object.mangas.order(:ranked).uniq(&:id)
  end

  def all_characters
    object.characters.order(:name).uniq(&:id)
  end
end
