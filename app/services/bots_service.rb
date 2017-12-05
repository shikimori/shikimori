# TODO: refactor
class BotsService
  def self.posters
    [16,15,14,13]
  end

  def self.get_poster
    if Rails.env.test?
      user = User.limit(1).first
      return user || FactoryBot.create(:user, nickname: 'bot_poster', email: 'bot_poster@gmail.com')
    end

    @@aka ||= User.find(16)
    @@minatsu ||= User.find(15)
    @@chizuru ||= User.find(14)
    @@mafuyu ||= User.find(13)
    @@posters ||= [@@aka, @@minatsu, @@chizuru, @@mafuyu]

    @@posters.sample
  end
end
