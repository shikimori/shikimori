describe Autocomplete::LicensorsController do
  describe '#index' do
    let(:phrase) { 'qqq' }

    before do
      allow(Search::Licensor)
        .to receive(:call)
        .with(phrase: 'Fff', kind: 'anime', ids_limit: Autocomplete::AutocompleteBase::LIMIT)
        .and_return ['aaa']
    end
    subject! { get :index, params: { search: 'Fff', kind: 'anime' } }

    it do
      expect(json).to eq ['aaa']
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
