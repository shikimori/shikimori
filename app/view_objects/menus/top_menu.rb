class Menus::TopMenu < ViewObjectBase
  ITEMS = [
    ## main
    # database
    {
      placement: :main,
      group: :database,
      url: :animes_collection_url,
      title: :'activerecord.models.anime',
      class: 'icon-letter-a'
    }, {
      placement: :main,
      group: :database,
      url: :mangas_collection_url,
      title: :'activerecord.models.manga',
      class: 'icon-letter-m'
    }, {
      placement: :main,
      group: :database,
      url: :ranobe_collection_url,
      title: :'activerecord.models.ranobe',
      class: 'icon-letter-r'
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
      class: 'icon-reviews'
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
      title: :'application.top_menu.contests',
      class: 'icon-contests'
    }, {
      placement: :main,
      group: :misc,
      url: :ongoings_pages_url,
      title: :calendar,
      class: 'icon-calendar'
    },
    # info
    {
      placement: :main,
      group: :info,
      url: :about_pages_url,
      title: :about_site,
      class: 'icon-info'
    }, {
      placement: :main,
      group: :info,
      if: ->(h) { h.ru_host? && !Rails.env.test? },
      url: ->(h) { StickyTopicView.socials(h.locale_from_host).url },
      title: :'application.top_menu.socials',
      class: 'icon-socials'
    }, {
      placement: :main,
      group: :info,
      if: ->(h) { h.user_signed_in? },
      url: :moderations_url,
      title: :'application.top_menu.moderation',
      class: 'icon-moderation'
    }
    ## profile
  ]

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
      all_items.find { |item| item.url == h.request.url } ||
      all_items.find { |item| h.request.url.starts_with?(item.url) }
  end

private

  def all_items # rubocop:disable AbcSize
    @all_items ||= ITEMS
      .map do |item|
        next if item[:if] && !item[:if].call(h)

        OpenStruct.new(
          placement: item[:placement],
          group: item[:group],
          title: item[:title].respond_to?(:call) ? item[:title].call(self) : h.t(item[:title]),
          css_class: item[:class],
          url: item[:url].respond_to?(:call) ? item[:url].call(h) : h.send(item[:url])
        )
      end
      .compact
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
