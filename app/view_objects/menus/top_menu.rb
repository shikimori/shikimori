class Menus::TopMenu < ViewObjectBase # rubocop:disable ClassLength
  MAIN_ITEMS = [
    # database
    {
      placement: :main,
      group: :database,
      url: :animes_collection_url,
      title: :'activerecord.models.anime',
      class: 'icon-anime'
    }, {
      placement: :main,
      group: :database,
      url: :mangas_collection_url,
      title: :'activerecord.models.manga',
      class: 'icon-manga'
    }, {
      placement: :main,
      group: :database,
      url: :ranobe_collection_url,
      title: :'activerecord.models.ranobe',
      class: 'icon-ranobe'
    },
    # community
    {
      placement: :main,
      group: :community,
      url: :clubs_url,
      title: ->(h) { h.i18n_i 'Club', :other },
      class: 'icon-clubs'
    }, {
      placement: :main,
      group: :community,
      url: :collections_url,
      title: ->(h) { h.i18n_i 'Collection', :other },
      class: 'icon-collections'
    }, {
      placement: :main,
      group: :community,
      url: ->(h) { h.forum_topics_url :reviews },
      title: ->(h) { h.i18n_i 'Review', :other },
      class: 'icon-reviews',
      search_url: ->(h) { h.forum_topics_url :reviews }
    }, {
      placement: :main,
      group: :community,
      url: :forum_url,
      title: :forum,
      class: 'icon-forum'
    },
    # misc
    {
      placement: :main,
      group: :misc,
      url: :contests_url,
      title: :'application.top_menu.items.contests',
      class: 'icon-contests'
    }, {
      placement: :main,
      group: :misc,
      url: :ongoings_pages_url,
      title: :calendar,
      class: 'icon-calendar',
      search_url: :animes_collection_url
    },
    # info
    {
      placement: :main,
      group: :info,
      url: :about_pages_url,
      title: :about_site,
      class: 'icon-info',
      search_url: false
    }, {
      placement: :main,
      group: :info,
      if: ->(h) { h.ru_host? && !Rails.env.test? },
      url: ->(h) { StickyTopicView.socials(h.locale_from_host).url },
      title: :'application.top_menu.items.socials',
      class: 'icon-socials',
      search_url: false
    }, {
      placement: :main,
      group: :info,
      if: ->(h) { h.user_signed_in? },
      url: :moderations_url,
      title: :'application.top_menu.items.moderation',
      class: 'icon-moderation',
      search_url: false
    }
  ]
  PROFILE_ITEMS = [
    # profile
    {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.current_user.url },
      title: :'application.top_menu.items.profile',
      class: 'icon-profile',
      search_url: false
    }, {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.profile_user_rates_url h.current_user, list_type: 'anime', subdomain: nil },
      title: :anime_list,
      class: 'icon-letter-a',
      search_url: false
    }, {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.profile_user_rates_url h.current_user, list_type: 'manga', subdomain: nil },
      title: :manga_list,
      class: 'icon-letter-m',
      search_url: false
    }, {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.current_user.unread_messages_url },
      title: :mail,
      class: 'icon-mail',
      search_url: false
    }, {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.profile_achievements_url h.current_user, subdomain: nil },
      title: ->(h) { h.i18n_i 'Achievement', :other },
      class: 'icon-achievements',
      search_url: false
    }, {
      placement: :profile,
      group: :profile,
      url: ->(h) { h.edit_profile_url h.current_user, page: :account, subdomain: nil },
      title: :settings,
      class: 'icon-settings',
      search_url: false
    }, {
      placement: :profile,
      group: :site,
      if: ->(_h) { !Rails.env.test? },
      url: ->(h) { StickyTopicView.site_rules(h.locale_from_host).url },
      title: :'application.top_menu.items.site_rules',
      class: 'icon-rules',
      search_url: false
    }, {
      placement: :profile,
      group: :site,
      if: ->(h) { h.ru_host? && !Rails.env.test? },
      url: ->(h) { StickyClubView.faq(h.locale_from_host).url },
      title: :'application.top_menu.items.faq',
      class: 'icon-faq',
      search_url: false
    }
  ]

  HIDDEN_ITEMS = [
    {
      url: :root_url,
      title: :'application.top_menu.items.home',
      class: 'icon-home',
      is_root: true
    }, {
      url: :achievements_url,
      title: ->(h) { h.i18n_i 'Achievement', :other },
      class: 'icon-achievements'
    }, {
      url: :characters_url,
      title: ->(h) { h.i18n_i 'Character', :other },
      class: 'icon-characters'
    }, {
      url: :people_url,
      title: ->(h) { h.i18n_i 'Person', :other },
      class: 'icon-people'
    }, {
      url: :users_url,
      title: ->(h) { h.i18n_i 'User', :other },
      class: 'icon-users'
    }
  ]

  OTHER_ITEM = {
    url: :root_url,
    title: :'application.top_menu.items.other',
    class: 'icon-other'
  }

  SHIKIMORI_ITEMS = MAIN_ITEMS + PROFILE_ITEMS + HIDDEN_ITEMS

  def groups placement
    all_items
      .select { |v| v.placement == placement }
      .map(&:group)
      .uniq
  end

  def items group
    all_items.select { |v| v.group == group }
  end

  def current_item
    @current_item ||=
      sorted_items.find { |item| item.url == request_url } ||
      sorted_items.find { |item| request_url.starts_with?(item.url) && !item.data[:is_root] } ||
      other_item
  end

  def current_item= item
    @current_item = build item
  end

  def search_url
    if current_item.data[:search_url].nil?
      current_item.url

    elsif current_item.data[:search_url] == false
      h.animes_collection_url

    else
      item_url current_item.data[:search_url]
    end
  end

private

  def all_items
    @all_items ||= SHIKIMORI_ITEMS
      .map { |item| build item }
      .compact
  end

  def sorted_items
    @sorted_items ||= all_items.sort_by(&:url).reverse
  end

  def other_item
    @other_item ||= build OTHER_ITEM
  end

  def build item
    return if item[:if] && !item[:if].call(h)

    OpenStruct.new(
      placement: item[:placement],
      group: item[:group],
      title: item_title(item[:title]),
      url: item_url(item[:url]),
      data: item
    )
  end

  def item_title value
    if value.respond_to?(:call)
      value.call(self)

    elsif value.is_a? Symbol
      h.t value

    else
      value
    end
  end

  def item_url value
    if value.is_a? String
      value

    elsif value.is_a? Symbol
      h.send value

    else
      value.call h
    end
  end

  def request_url
    @request_url ||= h.request.url.gsub(/\?.*|#.*/, '')
  end

  # def anime_seasons
  #   month = Time.zone.now.beginning_of_month
  #   # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
  #   is_still_this_year = (month + 2.months + 1.month).year == month.year

  #   [
  #     Titles::StatusTitle.new(:ongoing, Anime),
  #     Titles::SeasonTitle.new(month + 2.months, :year, Anime),
  #     Titles::SeasonTitle.new(is_still_this_year ? 1.year.ago : 2.months.ago, :year, Anime),
  #     Titles::SeasonTitle.new(month + 3.months, :season_year, Anime),
  #     Titles::SeasonTitle.new(month, :season_year, Anime),
  #     Titles::SeasonTitle.new(month - 3.months, :season_year, Anime),
  #     Titles::SeasonTitle.new(month - 6.months, :season_year, Anime)
  #   ]
  # end

  # def manga_kinds
  #   (Manga.kind.values - %w[novel]).map do |kind|
  #     Titles::KindTitle.new kind, Manga
  #   end
  # end

  # def ranobe_seasons
  #   month = Time.zone.now.beginning_of_month
  #   # + 1.month since 12th month belongs to the next year in Titles::SeasonTitle
  #   is_still_this_year = (month + 2.months + 1.month).year == month.year

  #   [
  #     Titles::StatusTitle.new(:ongoing, Ranobe),
  #     Titles::SeasonTitle.new(month + 2.months, :year, Ranobe),
  #     Titles::SeasonTitle.new(
  #       is_still_this_year ? 1.year.ago : 2.months.ago, :year, Ranobe
  #     ),
  #     Titles::SeasonTitle.new(
  #       is_still_this_year ? 2.years.ago : 14.months.ago, :year, Ranobe
  #     ),
  #     Titles::SeasonTitle.new(
  #       is_still_this_year ? 3.years.ago : 26.months.ago, :year, Ranobe
  #     )
  #   ].compact
  # end
end
