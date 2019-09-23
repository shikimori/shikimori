describe Autocomplete::FansubbersController do
  describe '#index' do
    let(:phrase) { 'qqq' }

    before do
      allow(Search::Fansubber)
        .to receive(:call)
        .with(phrase: 'Fff', kind: 'fansubber', ids_limit: Autocomplete::AutocompleteBase::LIMIT)
        .and_return ['aaa']
    end
    subject! { get :index, params: { search: 'Fff', kind: 'fansubber' } }

    it do
      expect(json).to eq ['aaa']
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
