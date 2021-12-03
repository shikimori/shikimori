class CloseAllSummaryAbuseRequests < ActiveRecord::Migration[5.2]
  def change
    AbuseRequest
      .where(kind: :summary, state: :pending)
      .update_all state: :rejected, approver_id: User::BANHAMMER_ID, updated_at: Time.zone.now
  end
end
