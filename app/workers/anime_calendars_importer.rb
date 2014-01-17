class AnimeCalendarsImporter
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform
    AnimeCalendar.parse
  end
end
