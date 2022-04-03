describe Api::V1::CalendarsController, :show_in_doc do
  include_context :timecop, '2016-09-05 15:00'

  describe '#show' do
    before do
      create :anime
      create :anime, :ongoing, aired_on: 1.day.ago
      create :anime, :ongoing, duration: 20
      create :anime, :ongoing, :ona
      create :anime, :ongoing, episodes_aired: 0, aired_on: 1.month.ago - 1.day
      create :anime, :anons
      create :anime, :anons
      create :anime, :anons, aired_on: 1.week.from_now
    end

    subject! { get :show, format: :json }

    it do
      expect(collection).to have(4).items

      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end
end
