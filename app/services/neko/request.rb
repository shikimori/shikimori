class Neko::Request
  method_object :params

  URL = 'http://localhost:4000/user_rate'

  def call
    data = JSON.parse post_request(@params).body, symbolize_names: true

    {
      added: parse(data[:added]),
      updated: parse(data[:updated]),
      removed: parse(data[:removed])
    }
  end

private

  def post_request params
    Faraday.post do |req|
      req.url URL
      req.headers['Authorization'] = 'foo'
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    end
  end

  def parse achievements
    achievements.map do |achievement|
      Neko::AchievementData.new achievement
    end
  end
end
