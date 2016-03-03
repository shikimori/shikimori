describe Api::V1::CharactersController, :show_in_doc do
  describe '#show' do
    let(:character) { create :character, :with_topic }
    before { get :show, id: character.id, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#search' do
    let!(:character_1) { create :character, name: 'asdf' }
    let!(:character_2) { create :character, name: 'zxcv' }
    before { get :search, q: 'asd', format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
