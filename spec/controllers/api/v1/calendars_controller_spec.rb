describe Api::V1::CalendarsController do
  describe '#show' do
    before do
      create :anime
      create :ongoing_anime, aired_on: Time.zone.now - 1.day
      create :ongoing_anime, duration: 20
      create :ongoing_anime, kind: 'ONA'
      create :ongoing_anime, episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month
      create :anons_anime
      create :anons_anime
      create :anons_anime, aired_on: Time.zone.now + 1.week
    end

    before { get :show, format: :json }
    specify { expect(assigns(:collection).size).to eq(3) }

    it { should respond_with :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
