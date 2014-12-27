describe StudiosController do
  let(:studio) { create :studio }
  let(:anime) { create :anime }

  before { anime.studios << studio }

  describe '#index' do
    before { get :index }

    it { should respond_with :success }
    it { expect(collection).to eq [studio] }
  end
end
