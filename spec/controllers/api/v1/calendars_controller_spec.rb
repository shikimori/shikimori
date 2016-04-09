describe Api::V1::CalendarsController, :show_in_doc do
  describe '#show' do
    before do
      create :anime
      create :anime, :ongoing, aired_on: Time.zone.now - 1.day
      create :anime, :ongoing, duration: 20
      create :anime, :ongoing, :ona
      create :anime, :ongoing, episodes_aired: 0, aired_on: Time.zone.now - 1.day - 1.month
      create :anime, :anons
      create :anime, :anons
      create :anime, :anons, aired_on: Time.zone.now + 1.week
    end

    before { get :show, format: :json }

    it do
      expect(collection).to have(3).items

      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
