describe TranslationsController do
  let!(:translations_club) { create :club, id: 2 }

  describe '#anime' do
    let!(:miyazaki) { create :person, id: 1870 }
    before { get :anime }
    it { expect(response).to have_http_status :success }
  end

  describe '#manga' do
    before { get :manga }
    it { expect(response).to have_http_status :success }
  end
end
