describe SeyuController, :type => :controller do
  let!(:seyu) { create :person, name: 'test', seyu: true }

  describe 'index' do
    let!(:person_2) { create :person, seyu: false }
    before { get :index, search: 'test', kind: 'seyu' }

    it { should respond_with :success }
    it { expect(assigns :collection).to eq [seyu] }
  end

  describe 'show' do
    before { get :show, id: seyu.to_param }

    context 'seyu' do
      let!(:seyu) { create :person, :with_thread, seyu: true }
      it { should respond_with :success }
    end

    context 'person' do
      let!(:seyu) { create :person, seyu: false }
      it { should redirect_to person_url(seyu) }
    end
  end

  describe 'roles' do
    before { get :roles, id: seyu.to_param }
    it { should respond_with :success }
  end

  describe 'comments' do
    let!(:seyu) { create :person, :with_thread, seyu: true }
    let!(:comment) { create :comment, commentable: seyu.thread }
    before { get :roles, id: seyu.to_param }
    it { should respond_with :success }
  end
end
