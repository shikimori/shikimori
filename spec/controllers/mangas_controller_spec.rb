describe MangasController do
  let(:manga) { create :manga }
  include_examples :db_entry_controller, :manga

  describe '#show' do
    let(:manga) { create :manga, :with_topics }

    describe 'id' do
      before { get :show, params: { id: manga.id } }
      it { expect(response).to redirect_to manga_url(manga) }
    end

    describe 'to_param' do
      before { get :show, params: { id: manga.to_param } }
      it { expect(response).to have_http_status :success }
    end

    describe 'not manga' do
      let(:manga) { create :ranobe }
      before { get :show, params: { id: manga.to_param } }
      it { expect(response).to redirect_to ranobe_url(manga) }
    end
  end

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
