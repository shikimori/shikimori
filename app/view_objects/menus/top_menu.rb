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
        title: :'application.top_menu.contests',
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
        title: :'application.top_menu.socials',
        class: 'icon-socials'
      }, {
        url: :moderations_url,
        title: :'application.top_menu.moderation',
        class: 'icon-moderation'
      }
    ]
  }

  def groups
    DATA.keys
  end

  def items group
    data.select { |v| v.group == group }
  end

  def current_item
    @current_item ||=
      data.find { |item| item.url == h.request.url } ||
      data.find { |item| h.request.url.starts_with?(item.url) }
  end

private

  def data # rubocop:disable AbcSize
    @data ||= DATA
      .flat_map do |group, items|
        items.map do |item|
          next if item[:if] && !item[:if].call(h)

          OpenStruct.new(
            group: group,
            title: item[:title].respond_to?(:call) ? item[:title].call(self) : h.t(item[:title]),
            css_class: item[:class],
            url: item[:url].respond_to?(:call) ? item[:url].call(h) : h.send(item[:url])
          )
        end
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
