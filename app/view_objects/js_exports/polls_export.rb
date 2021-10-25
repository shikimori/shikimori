class JsExports::PollsExport < JsExports::ExportBase
  private

  def fetch_entries _user
    Poll
      .includes(:variants)
      .where(id: tracked_ids)
      .order(:id)
  end

  def serialize poll, user, _ability
    PollSerializer.new(poll, scope: user).to_hash
  end
end
