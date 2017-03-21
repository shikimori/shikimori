describe UsersController do
  let!(:user_1) { create :user, nickname: 'zzz Ffff' }
  let!(:user_2) { create :user, nickname: 'Fffff' }
  let!(:user_3) { create :user, nickname: 'Ff' }

  describe '#index' do
    describe 'whole collection' do
      before { get :index }
      it do
        expect(collection).to have(5).items # 3 from let + 2 from seeds
        expect(response).to have_http_status :success
      end
    end

    describe 'search' do
      before { get :index, params: { search: 'Fff' } }
      it do
        expect(collection).to eq [user_2, user_1]
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#autocomplete' do
    before { get :autocomplete, params: { search: 'Fff' } }

    it do
      expect(collection).to eq [user_1, user_2]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
