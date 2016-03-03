describe SeyuController do
  let!(:seyu) { create :person, name: 'test', seyu: true }
  let!(:role) { create :person_role, anime: create(:anime), person: seyu, role: 'Japanese' }

  describe '#index' do
    let!(:person_2) { create :person, seyu: false }
    before { get :index, search: 'test', kind: 'seyu' }

    it { expect(response).to have_http_status :success }
    it { expect(assigns :collection).to eq [seyu] }
  end

  describe '#show' do
    let!(:seyu) { create :person, :with_topic, seyu: true }
    before { get :show, id: seyu.to_param }

    context 'seyu' do
      it { expect(response).to have_http_status :success }
    end

    context 'person' do
      let!(:role) { }
      it { expect(response).to redirect_to person_url(seyu) }
    end
  end

  describe '#roles' do
    before { get :roles, id: seyu.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#comments' do
    let!(:seyu) { create :person, :with_topic, seyu: true }
    let!(:comment) { create :comment, commentable: seyu.topic }
    before { get :roles, id: seyu.to_param }

    it { expect(response).to have_http_status :success }
  end
end
