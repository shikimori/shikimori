class ClubDecorator < DbEntryDecorator # rubocop:disable ClassLength
  instance_cache :description, :animes, :mangas, :characters, :images,
    :comments, :banned, :menu_members, :forum_topics_views,
    :all_images

  MENU_ENTRIES = 12
  MENU_OTHER = 4
  FORUM_TOPICS = 4
  LINKED_KINDS = %i[animes mangas ranobe characters clubs collections]

  LINKED_PER_PAGE = 20
  LINKED_ORDER = {
    animes: :ranked,
    mangas: :ranked,
    ranobe: :ranked,
    characters: ->(h) { h.localization_field },
    collections: :name
  }

  delegate :description, to: :object

  LINKED_KINDS.each do |kind| # rubocop:disable BlockLength
    define_method kind do
      scope = respond_to?(:"all_#{kind}") ? send(:"all_#{kind}") : object.send(kind)

      scope = scope.order(
        LINKED_ORDER[kind].respond_to?(:call) ?
          LINKED_ORDER[kind].call(h) :
          LINKED_ORDER[kind]
      )

      QueryObjectBase
        .new(scope)
        .paginate(page, LINKED_PER_PAGE)
        .lazy_map(&:decorate)
    end

    define_method :"menu_#{kind}" do
      entries = send(:"all_#{kind}").shuffle

      entries
        .take(entries.first.is_a?(DbEntry) ? MENU_ENTRIES : MENU_OTHER)
        .sort_by do |entry|
          if entry.respond_to? :ranked
            entry.ranked
          elsif entry.respond_to? :russian
            h.localized_name entry
          else
            entry.name
          end
        end
    end
  end

  def url
    h.club_url object
  end

  def new_topic_url
    h.new_club_club_topic_path(
      object,
      'topic[type]' => Topics::ClubUserTopic.name,
      'topic[user_id]' => h.current_user.id,
      'topic[forum_id]' => Forum.find_by_permalink('clubs').id, # rubocop:disable DynamicFindBy
      'topic[linked_id]' => object.id,
      'topic[linked_type]' => Club.name
    )
  end

  def description_html
    html =
      Rails.cache
        .fetch(CacheHelperInstance.cache_keys(:description_html, object, CACHE_VERSION)) do
          BbCodes::Text.call description
        end

    html.presence || "<p class='b-nothing_here'>#{i18n_t 'no_description'}</p>".html_safe
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
    member_roles.find { |v| v.user_id == h.current_user.id }&.role if h.user_signed_in?
  end

  def menu_members
    all_member_roles.where(role: :member).limit(12).map(&:user)
  end

  def menu_linked_cache_key
    [
      object,
      :menu
    ] + LINKED_KINDS.map { |kind| object.send(kind).cache_key }
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

  def forum_topics_query
    Topics::Query.fetch(h.censored_forbidden?)
      .by_forum(Forum.find_by_permalink('clubs'), h.current_user, false) # rubocop:disable DynamicFindBy
      .by_linked(object)
      .where("topics.type != '#{Topics::EntryTopics::ClubTopic.name}'")
  end

  def forum_topics_views
    forum_topics_query.paginate(1, FORUM_TOPICS).as_views(true, true)
  end

private

  def all_images
    return [] unless display_images?

    object
      .images
      .order(created_at: :desc)
  end

  def all_clubs
    Clubs::Query.new(object.clubs).without_shadowbanned(h.current_user)
  end
end
