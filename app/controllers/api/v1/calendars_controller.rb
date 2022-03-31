class Api::V1::CalendarsController < Api::V1Controller
  api :GET, '/calendar', 'Show a calendar'
  param :censored, %w[true false],
    required: false,
    desc: 'Set to `false` to allow hentai, yaoi and yuri'
  def show
    scope =
      if Animes::Filters::Policy.exclude_hentai?(params)
        Animes::Query.new(Anime.all).exclude_hentai
      else
        Anime.all
      end
    @collection = CalendarsQuery.new(scope).fetch

    respond_with @collection,
      each_serializer: CalendarEntrySerializer,
      root: true
  end
end
