describe MangasController do
  let(:manga) { create :manga }
  include_examples :db_entry_controller, :manga
end
