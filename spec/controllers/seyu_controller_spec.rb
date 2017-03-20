describe SeyuController do
  let!(:seyu) { create :person, name: 'test', seyu: true }
  let!(:role) { create :person_role, anime: create(:anime), person: seyu, role: 'Japanese' }

  describe '#index' do
    let!(:person_2) { create :person, seyu: false }
    before do
      allow(Search::Person).to receive(:call) do |params|
        params[:scope].where(id: seyu.id)
      end
    end
    before { get :index, params: { search: 'test', kind: 'seyu' } }

    it do
      expect(response).to have_http_status :success
      expect(assigns :collection).to eq [seyu]
    end
  end

  describe '#show' do
    let!(:seyu) { create :person, :with_topics, seyu: true }
    before { get :show, params: { id: seyu.to_param } }

    context 'seyu' do
      it { expect(response).to have_http_status :success }
    end

    context 'person' do
      let!(:role) { }
      it { expect(response).to redirect_to person_url(seyu) }
    end
  end

  describe '#roles' do
    before { get :roles, params: { id: seyu.to_param } }
    it { expect(response).to have_http_status :success }
  end
end
