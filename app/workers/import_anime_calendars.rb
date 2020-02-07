class ImportAnimeCalendars
  include Sidekiq::Worker

  CALENDAR_URL = 'http://animecalendar.eu/user/ical/8831/e599e8323643658c14eef67e85bdb534'
  FIXES = YAML.load_file(Rails.root.join('config/app/animecalendar.yml'))

  def perform
    calendars = match exclude parse calendars_data
    import calendars
    process_results calendars
  end

private

  def process_results calendars
    names = calendars.map { |v| v[:title] }.uniq
    imported = filter(calendars).map { |v| v[:title] }.uniq

    Rails.cache.write 'calendar_unrecognized', (names - imported - FIXES[:ignores])

    { imported: imported, unrecognized: names - imported - FIXES[:ignores] }
  end

  def import calendars
    models = filter(calendars)
      .map { |v| build v }
      .uniq { |v| "#{v.anime_id} #{v.episode}" }

    AnimeCalendar.transaction do
      AnimeCalendar.delete_all
      AnimeCalendar.import models
    end
  end

  def filter calendars
    calendars.select do |calendar|
      calendar[:anime] && (calendar[:anime].anons? || calendar[:anime].ongoing?)
    end
  end

  def build calendar
    AnimeCalendar.new(
      episode: calendar[:episode],
      start_at: calendar[:start_at],
      anime: calendar[:anime]
    )
  end

  def match calendars
    calendars.each do |calendar|
      calendar[:anime] =
        if FIXES[:matches][calendar[:title]]
          find_anime FIXES[:matches][calendar[:title]]
        else
          match_anime calendar[:title]
        end
    end
  end

  def exclude calendars
    calendars.select { |calendar| calendar[:start_at] >= Time.zone.now }
  end

  def parse i_calendars
    i_calendars.first.events.map do |i_data|
      data = Array(i_data.summary).last.split(' Ep: ')
      episode = data.second.to_i
      title = data.first.strip

      {
        anime: nil,
        title: title,
        start_at: i_data.dtstart - 4.hours,
        episode: episode - (FIXES[:episodes_diff][title] || 0)
      }
    end
  end

  def calendars_data
    raw_data = Rails.cache.fetch(:ical_calendar, expires_in: 1.hours) do
      OpenURI.open_uri(CALENDAR_URL).read
    end

    Icalendar::Calendar.parse raw_data
  end

  def find_anime anime_id
    @db_cache ||= {}

    if @db_cache.key?(anime_id)
      @db_cache[anime_id]
    else
      @db_cache[anime_id] = Anime.find_by id: anime_id
    end
  end

  def match_anime name
    @matches_cache ||= {}

    if @matches_cache.key?(name)
      @matches_cache[name]

    else
      matches = matches(name, status: :anons)
      matches = matches(name, status: :ongoing) if matches.blank?
      matches = matches(name) if matches.blank?

      @matches_cache[name] = matches.one? ? matches.first : nil
    end
  end

  def matches name, options = {}
    NameMatches::FindMatches.call name, Anime, options
  end
end
