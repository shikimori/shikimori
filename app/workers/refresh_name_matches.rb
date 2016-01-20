class RefreshNameMatches
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform target_type
    NameMatch.transaction do
      NameMatch.where(target_type: target_type).delete_all
    end
  end
end
