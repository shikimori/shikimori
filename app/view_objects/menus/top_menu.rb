class Menus::TopMenu < ViewObjectBase # rubocop:disable ClassLength
  MAIN_ITEMS = [
    # database
    {
      name: :anime,
      placement: :main,
      group: :database,
      url: :animes_collection_url,
      search_url: ->(h) {
        h.params[:controller] == 'animes_collection' ?
          h.current_url(search: nil) :
          h.animes_collection_url
      }
    }, {
      name: :manga,
      placement: :main,
      group: :database,
      url: :mangas_collection_url,
      search_url: ->(h) {
        h.params[:controller] == 'animes_collection' ?
          h.current_url(search: nil) :
          h.mangas_collection_url
      }
    }, {
      name: :ranobe,
      placement: :main,
      group: :database,
      url: :ranobe_collection_url,
      search_url: ->(h) {
        h.params[:controller] == 'animes_collection' ?
          h.current_url(search: nil) :
          h.ranobe_collection_url
      }
    },
    # community
    {
      name: :clubs,
      placement: :main,
      group: :community,
      url: :clubs_url
    }, {
      name: :collections,
      placement: :main,
      group: :community,
      url: :collections_url
    }, {
      name: :reviews,
      placement: :main,
      group: :community,
      url: ->(h) { h.forum_topics_url :reviews },
      search_url: ->(h) { h.forum_topics_url :reviews }
    }, {
      name: :forum,
      placement: :main,
      group: :community,
      url: :forum_url
    },
    {
      name: :users,
      placement: :main,
      group: :community,
      url: :users_url
    },
    # misc
    {
      name: :contests,
      placement: :main,
      group: :misc,
      url: :contests_url
    }, {
      name: :calendar,
      placement: :main,
      group: :misc,
      url: :ongoings_pages_url,
      search_url: :animes_collection_url
    },
    # info
    {
      name: :info,
      placement: :main,
      group: :info,
      url: :about_pages_url,
      search_url: false
    }, {
      name: :socials,
      placement: :main,
      group: :info,
      if: ->(h) { h.ru_host? && !Rails.env.test? },
      url: ->(h) { StickyTopicView.socials(h.locale_from_host).url },
      search_url: false
    }, {
      name: :moderation,
      placement: :main,
      group: :info,
      if: :user_signed_in?,
      url: :moderations_url,
      search_url: false
    }
  ]
  PROFILE_ITEMS = [
    # profile
    {
      name: :profile,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.current_user.url },
      search_url: false
    }, {
      name: :anime_list,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.profile_user_rates_url h.current_user, list_type: 'anime', subdomain: nil },
      search_url: false
    }, {
      name: :manga_list,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.profile_user_rates_url h.current_user, list_type: 'manga', subdomain: nil },
      search_url: false
    }, {
      name: :mail,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.current_user.unread_messages_url },
      search_url: false
    }, {
      name: :achievements,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.profile_achievements_url h.current_user, subdomain: nil },
      search_url: false
    }, {
      name: :settings,
      placement: :profile,
      group: :profile,
      if: :user_signed_in?,
      url: ->(h) { h.edit_profile_url h.current_user, page: :account, subdomain: nil },
      search_url: false
    }, {
      name: :site_rules,
      placement: :profile,
      group: :site,
      if: ->(_h) { !Rails.env.test? },
      url: ->(h) { StickyTopicView.site_rules(h.locale_from_host).url },
      search_url: false
    }, {
      name: :faq,
      placement: :profile,
      group: :site,
      if: ->(h) { h.ru_host? && !Rails.env.test? },
      url: ->(h) { StickyClubView.faq(h.locale_from_host).url },
      search_url: false
    }
  ]

  HIDDEN_ITEMS = [
    {
      name: :home,
      url: :root_url,
      is_root: true
    }, {
      name: :achievements,
      url: :achievements_url
    }, {
      name: :characters,
      url: :characters_url
    }, {
      name: :people,
      url: :people_url
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
    return if if_condition(item[:if])

    OpenStruct.new(
      placement: item[:placement],
      group: item[:group],
      title: item_title(item[:name], item[:title]),
      url: item_url(item[:url]),
      data: item
    )
  end

  def item_title name, title
    if title.respond_to?(:call)
      title.call(self)

    elsif title.is_a? Symbol
      h.t title

    elsif title.is_a? String
      title

    else
      h.t "application.top_menu.items.#{name}"
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

  def if_condition item_if
    return false unless item_if

    if item_if.is_a? Symbol
      !h.send(item_if)
    else
      !item_if.call(h)
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
