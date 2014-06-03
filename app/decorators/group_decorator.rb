class GroupDecorator < BaseDecorator
  VisibleEntries = 12

  rails_cache :description_html, :all_members, :all_animes, :all_mangas, :all_characters, :all_images
  instance_cache :description, :animes, :mangas, :characters, :images, :comments, :banned

  def url
    h.club_url object
  end

  def image
    object.logo
  end

  def description_html
    BbCodeFormatter.instance.format_comment object.description
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
    all_members.take 9
  end

  def all_animes
    object
      .animes
      .order(:ranked)
      .uniq(&:id)
  end

  def animes
    all_animes
      .shuffle
      .take(VisibleEntries)
      .sort_by(&:ranked)
  end

  def all_mangas
    object
      .mangas
      .order(:ranked)
      .uniq(&:id)
  end

  def mangas
    all_mangas
      .shuffle
      .take(VisibleEntries)
      .sort_by(&:ranked)
  end

  def all_characters
    object
      .characters
      .order(:name)
      .uniq(&:id)
  end

  def characters
    all_characters
      .shuffle
      .take(VisibleEntries)
      .sort_by(&:name)
  end

  def all_images
    return [] unless display_images?
    object
      .images
      .order(created_at: :desc)
  end

  def images
    all_images.take(12)
  end

  def comments
    object
      .thread
      .comments
      .with_viewed(h.current_user)
      .limit(15)
      .to_a
  end

  def show_comments?
    h.user_signed_in? || comments.any?
  end

  def banned
    bans.includes(:user).map(&:user)
  end

  # для отображения топиков клуба на форуме
  def topics
    []
  end

  # для отображения топиков клуба на форуме
  def news
    []
  end
end
