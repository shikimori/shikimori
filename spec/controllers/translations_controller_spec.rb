describe TranslationsController do
  let!(:translations_club) { create :club, id: 2 }

  describe '#anime' do
    let!(:miyazaki) { create :person, id: 1870 }
    before { get :show, params: { anime: true } }
    it { expect(response).to have_http_status :success }
  end

  describe '#manga' do
    before { get :show, params: { manga: true } }
    it { expect(response).to have_http_status :success }
  end
end
