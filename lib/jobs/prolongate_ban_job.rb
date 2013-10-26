class ProlongateBanJob < Struct.new(:user_id)
  def perform
    User.find(user_id).prolongate_ban
  end
end
