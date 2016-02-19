class ProlongateBan
  include Sidekiq::Worker
  sidekiq_options queue: :critical

  # исключения, у которых ip совпадают с забаненными троллями
  IGNORED_IDS = [3581]
  SAFE_INTERVAL = 3.weeks

  def perform user_id
    # return if IGNORED_IDS.include? user_id

    # user = User.find_by_id user_id
    # return if user.created_at < SAFE_INTERVAL.ago

    # read_only_at = User
      # .where(current_sign_in_ip: user.current_sign_in_ip)
      # .select { |v| v.read_only_at.present? && v.read_only_at > Time.zone.now }
      # .map { |v| v.read_only_at }
      # .max

    # user.update_column :read_only_at, read_only_at
  end
end
