class ClubDecorator < DbEntryDecorator
  MENU_ENTRIES = 12

  rails_cache :all_animes, :all_mangas, :all_characters, :all_images
  instance_cache :description, :animes, :mangas, :characters, :images,
    :comments, :banned, :members_sample

  def url
    h.club_url object
  end

  def new_topic_url
    h.new_club_club_topic_path(
      object,
      'topic[type]' => Topics::ClubUserTopic.name,
      'topic[user_id]' => h.current_user.id,
      'topic[forum_id]' => Forum.find_by_permalink('clubs').id,
      'topic[linked_id]' => object.id,
      'topic[linked_type]' => Club.name
    )
  end

  def image
    object.logo
  end

  def all_member_roles
    member_roles
      .includes(:user)
      .order(created_at: :desc)
  end

  def user_role
    if h.user_signed_in?
      member_roles.find { |v| v.user_id == h.current_user.id }&.role
    end
  end

  def members_sample
    all_member_roles.where(role: :member).limit(12).map(&:user)
  end

  def animes
    all_animes
  end

  def mangas
    all_mangas
  end

  def characters
    all_characters
  end

  def menu_animes
    all_animes
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:ranked)
  end

  def menu_mangas
    all_mangas
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:ranked)
  end

  def menu_characters
    all_characters
      .shuffle
      .take(MENU_ENTRIES)
      .sort_by(&:name)
  end

  def images limit = 10_000
    all_images.take limit
  end

  def show_comments?
    h.user_signed_in? || comments.any?
  end

  def new_invite
    invites.new(src: h.current_user)
  end

  def menu_pages club_page = nil
    (club_page&.child_pages || object.root_pages).select(&:layout_menu?)
  end

private

  def all_images
    return [] unless display_images?
    object
      .images
      .order(created_at: :desc)
  end

  def all_animes
    object.animes.order(:ranked).decorate
  end

  def all_mangas
    object.mangas.order(:ranked).decorate
  end

  def all_characters
    object.characters.order(:name).decorate
  end
end
