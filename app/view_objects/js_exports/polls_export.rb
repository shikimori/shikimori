class JsExports::PollsExport < JsExports::ExportBase
private

  def fetch_entries user
    Poll
      .where.not(state: :pending)
      .where(id: tracked_ids)
      .order(:id)
  end

  def serialize poll, user
    PollSerializer.new(poll).to_hash
  end
end
