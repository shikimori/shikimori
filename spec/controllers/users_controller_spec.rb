describe UsersController do
  describe '#index' do
    let!(:user_1) { create :user, nickname: 'zzz Ffff' }
    let!(:user_2) { create :user, nickname: 'Fffff' }
    let!(:user_3) { create :user, nickname: 'Ff' }

    describe 'whole collection' do
      before { get :index }
      it { should respond_with :success }
      it { expect(collection).to have(3).items }
    end

    describe 'search' do
      before { get :index, search: 'Fff' }
      it { should respond_with :success }
      it { expect(collection).to eq [user_2, user_1] }
    end
  end

  describe '#autocomplete' do
    let!(:user_1) { create :user, nickname: 'zzz Ffff' }
    let!(:user_2) { create :user, nickname: 'Fffff' }
    let!(:user_3) { create :user, nickname: 'Ff' }

    before { get :autocomplete, search: 'Fff' }

    it { should respond_with :success }
    it { expect(collection).to eq [user_1, user_2] }
    it { expect(response.content_type).to eq 'application/json' }
  end
end
