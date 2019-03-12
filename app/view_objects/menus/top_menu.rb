class Menus::TopMenu < ViewObjectBase
  DATA = {
    database: [
      {
        url: :animes_collection_url,
        title: :'activerecord.models.anime',
        class: 'icon-letter-a'
      }, {
        url: :mangas_collection_url,
        title: :'activerecord.models.manga',
        class: 'icon-letter-m'
      }, {
        url: :ranobe_collection_url,
        title: :'activerecord.models.ranobe',
        class: 'icon-letter-r'
      }
    ],
    community: [
      {
        url: :clubs_url,
        title: ->(h) { h.i18n_i 'Club', :other },
        class: 'icon-clubs'
      }, {
        url: :collections_url,
        title: ->(h) { h.i18n_i 'Collection', :other },
        class: 'icon-collections'
      }, {
        url: ->(h) { h.forum_topics_url :reviews },
        title: ->(h) { h.i18n_i 'Review', :other },
        class: 'icon-reviews'
      }, {
        url: :forum_url,
        title: :forum,
        class: 'icon-forum'
      }
    ],
    misc: [
      {
        url: :contests_url,
        title: :'.contests',
        class: 'icon-contests'
      }, {
        url: :ongoings_pages_url,
        title: :calendar,
        class: 'icon-calendar'
      }
    ],
    info: [
      {
        url: :about_pages_url,
        title: :about_site,
        class: 'icon-info'
      }, {
        if: ->(h) { h.ru_host? && !Rails.env.test? },
        url: ->(h) { StickyTopicView.socials(h.locale_from_host).url },
        title: :'.socials',
        class: 'icon-socials'
      }, {
        url: :moderations_url,
        title: :'.moderation',
        class: 'icon-moderation'
      }
    ]
  }

  def groups
    DATA.keys
  end

  def items group
    DATA[group]
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
