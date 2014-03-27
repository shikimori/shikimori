class YandexMetrika
  APP_ID = 'ef0aa97bc35b4ccbada9e0d79aeb17f7'
  APP_SECRET = 'f873d40b9ec54c479c0560fb5d365dab'
  APP_TOKEN = 'a7ead542b7b54482be10a27598ec2731'
  APP_COUNTER_ID = 7915231

  def traffic_for_months months
    count = [3, months].max / 3 - 1

    count.downto(0).map do |i|
      traffic Date.yesterday - ((i+1)*3).month, Date.yesterday - ((i)*3).month
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
      .reverse
      .map do |entry|
        TrafficEntry.new entry['date'].sub(/(\d{4})(\d\d)(\d\d)/, '\1-\2-\3'), entry['visitors'], entry['visits'], entry['page_views']
      end
  end
end
