# получить новый токен https://oauth.yandex.ru/authorize?response_type=token&client_id=<идентификатор приложения>
class YandexMetrika
  APP_ID = 'b658b57e3a5b4370a0448fc9ba85f129'
  APP_SECRET = '51bd8685f0074421895b4965eec15250'
  APP_TOKEN = 'c751573157874acea30ba2ec46b9f6db'
  APP_COUNTER_ID = 7915231

  def traffic_for_months months
    count = [3, months].max / 3 - 1

    count.downto(0).map do |i|
      traffic Time.zone.yesterday - ((i+1)*3).month, Time.zone.yesterday - ((i)*3).month
    end.sum.uniq {|v| v['date'] }
  end

private
  def client
    @client ||= begin
      ym = Metrika::Client.new APP_ID, APP_SECRET
      ym.restore_token APP_TOKEN
      ym
    end
  end

  def traffic from, to
    client
      .get_counter_stat_traffic_summary(APP_COUNTER_ID, group: :day, date1: from, date2: to)['data']
      .map do |entry|
        TrafficEntry.new(
          entry['date'].sub(/(\d{4})(\d\d)(\d\d)/, '\1-\2-\3'),
          entry['visitors'],
          entry['visits'],
          entry['page_views']
        )
      end.sort_by(&:date)
  end
end
