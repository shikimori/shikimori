describe MangasController do
  let(:manga) { create :manga }
  include_examples :db_entry_controller, :manga

  describe '#autocomplete' do
    let(:manga) { build_stubbed :manga }
    let(:phrase) { 'qqq' }

    before { allow(Autocomplete::Manga).to receive(:call).and_return [manga] }
    before { get :autocomplete, params: { search: 'Fff' } }

    it do
      expect(collection).to eq [manga]
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
