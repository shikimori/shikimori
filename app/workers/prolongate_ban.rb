class ProlongateBan
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform user_id
    User.find_by_id(user_id).try :prolongate_ban
  end
end
