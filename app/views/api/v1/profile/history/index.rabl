collection @resources

attribute :id, :created_at, :target_id, :target_type

node :description do |entry|
  UserPresenter.history_entry_text entry
end

node :target_url do |entry|
  url_for entry.target if entry.target
end
