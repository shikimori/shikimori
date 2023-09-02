# получить новый токен
# https://oauth.yandex.ru/authorize?response_type=token&client_id=b658b57e3a5b4370a0448fc9ba85f129
class YandexMetrika
  API_URL = 'https://api-metrika.yandex.ru/analytics/v3/data/ga'
  APP_ID = 'b658b57e3a5b4370a0448fc9ba85f129'
  APP_COUNTER_IDS = [53_670_769, 93_211_525]

  method_object :months

  def call # rubocop:disable Metrics/AbcSize
    # it is split on many requests because yandex rounds(3) all metrics on
    # requests with longer intervals
    from_month
      .downto(0)
      .flat_map do |i|
        traffic(
          (((i + 1) * 3).months.ago - 1.day).to_date.to_s,
          ((i * 3).months.ago - 1.day).to_date.to_s
        )
      end
      .uniq(&:date)
  end

private

  def from_month
    (([3, @months].max / 3) - 1)
  end

  # open(api_url(date_from, date_to), "Authorization: #{APP_TOKEN}").read
  def traffic date_from, date_to # rubocop:disable Metrics/AbcSize
    APP_COUNTER_IDS
      .each_with_object({}) do |app_counter_id, memo|
        json_data(app_counter_id, date_from, date_to).map do |entry|
          memo[entry[0]] ||= traffic_entry entry[0]

          memo[entry[0]].visitors += entry[1].to_i
          memo[entry[0]].visits += entry[2].to_i
          memo[entry[0]].page_views += entry[3].to_i
        end
      end
      .values
  end

  def json_data app_counter_id, date_from, date_to
    JSON.parse(
      OpenURI.open_uri(
        api_url(app_counter_id, date_from, date_to),
        'Authorization' => "OAuth #{oauth_token}"
      ).read
    )['rows']
  end

  def api_url app_counter_id, date_from, date_to
    API_URL +
      "?ids=ga:#{app_counter_id}" \
        '&metrics=ga:users,ga:sessions,ga:pageviews' \
        '&dimensions=ga:date' \
        '&sort=ga:date' \
        "&start-date=#{date_from}" \
        "&end-date=#{date_to}"
  end

  def oauth_token
    Rails.application.secrets.yandex_metrika[:oauth_token]
  end

  def traffic_entry date_string
    TrafficEntry.new(
      date: Time.zone.parse(date_string).to_date,
      visitors: 0,
      visits: 0,
      page_views: 0
    )
  end
end
