describe RanobeController do
  let(:ranobe) { create :ranobe }
  include_examples :db_entry_controller, :ranobe

  describe '#show' do
    let(:ranobe) { create :ranobe, :with_topics }

    describe 'id' do
      before { get :show, params: { id: ranobe.id } }
      it { expect(response).to redirect_to ranobe_url(ranobe) }
    end

    describe 'to_param' do
      before { get :show, params: { id: ranobe.to_param } }
      it { expect(response).to have_http_status :success }
    end

    describe 'not ranobe' do
      let(:ranobe) { create :manga }
      before { get :show, params: { id: ranobe.to_param } }
      it { expect(response).to redirect_to manga_url(ranobe) }
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
