class AnimeCalendarJob
  def perform
    AnimeCalendar.parse
  end
end
