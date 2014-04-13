class ProlongateBan
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  def perform user_id
    return if user_id == 3581 # Ametrin - у него ip совпадает с одним троллем
    User.find_by_id(user_id).try :prolongate_ban
  end
end
