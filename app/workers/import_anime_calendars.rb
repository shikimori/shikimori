class ImportAnimeCalendars
  include Sidekiq::Worker

  CALENDAR_URL = 'http://animecalendar.net/user/ical/8831/e599e8323643658c14eef67e85bdb534'
  FIXES = YAML.load_file(Rails.root.join 'config/animecalendar.yml')

  def perform
    calendars = match parse calendars_data
    import calendars
    #ap filter(calendars)
    process_results calendars
  end

private

  def process_results calendars
    names = calendars.map {|v| v[:title] }.uniq
    imported = filter(calendars).map {|v| v[:title] }.uniq

    Rails.cache.write 'calendar_unrecognized', (names - imported)

    { imported: imported, unrecognized: names - imported - FIXES[:ignores] }
  end

  def import calendars
    models = filter(calendars).map {|v| build v }

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
      if FIXES[:matches][calendar[:title]]
        calendar[:anime] = Anime.find(FIXES[:matches][calendar[:title]])

      else
        matches = matcher.matches calendar[:title], status: :anons
        matches = matcher.matches calendar[:title], status: :ongoing if matches.blank?
        matches = matcher.matches calendar[:title] if matches.blank?

        calendar[:anime] = matches.first if matches.one?
      end
    end
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
        episode: episode - (FIXES[:episodes_diff][title] || 0),
      }
    end
  end

  def calendars_data
    Icalendar.parse open(CALENDAR_URL).read
  end

  def matcher
    @matcher ||= NameMatcher.new Anime
  end
end
