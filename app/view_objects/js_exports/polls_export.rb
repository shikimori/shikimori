class JsExports::PollsExport < JsExports::ExportBase
  private

  def fetch_entries _user
    Poll
      .includes(:variants)
      .where(id: tracked_ids)
      .order(:id)
      .limit(30) # the same limit is in PollsTracker
  end

  def serialize poll, user, _ability
    PollSerializer.new(poll, scope: user).to_hash
  end
end
