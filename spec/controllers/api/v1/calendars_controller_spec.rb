describe Api::V1::CalendarsController do
  describe '#show' do
    before do
      create :anime
      create :anime, :ongoing, aired_on: Time.zone.now - 1.day
      create :anime, :ongoing, duration: 20
      create :anime, :ongoing, kind: 'ONA'
      create :anime, :ongoing, episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month
      create :anime, :anons
      create :anime, :anons
      create :anime, :anons, aired_on: Time.zone.now + 1.week
    end

    before { get :show, format: :json }
    specify { expect(assigns(:collection).size).to eq(4) }

    it { expect(response).to have_http_status :success }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
