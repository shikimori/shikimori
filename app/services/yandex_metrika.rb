# получить новый токен
# https://oauth.yandex.ru/authorize?response_type=token&client_id=b658b57e3a5b4370a0448fc9ba85f129
class YandexMetrika
  API_URL = 'https://api-metrika.yandex.ru/analytics/v3/data/ga'

  APP_ID = 'b658b57e3a5b4370a0448fc9ba85f129'
  APP_SECRET = '51bd8685f0074421895b4965eec15250'
  APP_TOKEN = 'c751573157874acea30ba2ec46b9f6db'
  APP_COUNTER_ID = 53_670_769

  method_object :months

  def call # rubocop:disable AbcSize
    # it is split on many requests because yandex rounds(3) all metrics on
    # requests with longer intervals
    ([3, @months].max / 3 - 1).downto(0)
      .map do |i|
        traffic(
          (((i + 1) * 3).months.ago - 1.day).to_date.to_s,
          ((i * 3).months.ago - 1.day).to_date.to_s
        )
      end
      .sum
      .uniq(&:date)
  end

private

  # open(api_url(date_from, date_to), "Authorization: #{APP_TOKEN}").read
  def traffic date_from, date_to
    json_data(date_from, date_to).map do |entry|
      TrafficEntry.new(
        date: Time.zone.parse(entry[0]).to_date,
        visitors: entry[1],
        visits: entry[2],
        page_views: entry[3]
      )
    end
  end

  def json_data date_from, date_to
    JSON.parse(OpenURI.open_uri(api_url(date_from, date_to)).read)['rows']
  end

  def api_url date_from, date_to
    API_URL +
      "?ids=ga:#{APP_COUNTER_ID}"\
      '&metrics=ga:users,ga:sessions,ga:pageviews'\
      '&dimensions=ga:date'\
      '&sort=ga:date'\
      "&start-date=#{date_from}"\
      "&end-date=#{date_to}"
  end
end
