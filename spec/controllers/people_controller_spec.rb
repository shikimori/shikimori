describe PeopleController do
  let!(:person) { create :person }

  describe '#index' do
    let!(:person_2) { create :person, name: 'test', mangaka: true }
    before { get :index, search: 'test', kind: 'mangaka' }

    it { expect(response).to have_http_status :success }
    it { expect(assigns :collection).to eq [person_2] }
  end

  describe '#show' do
    let!(:person) { create :person, :with_topic, mangaka: true }
    before { get :show, id: person.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#works' do
    let!(:manga) { create :manga, person_roles: [create(:person_role, person: person, role: 'Director')] }
    before { get :works, id: person.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: person }
    before { get :favoured, id: person.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#comments' do
    let(:person) { create :person, :with_topic }
    let!(:comment) { create :comment, commentable: person.topic }
    before { get :comments, id: person.to_param }

    it { expect(response).to redirect_to UrlGenerator.instance
      .topic_url(person.topic) }
  end

  describe '#tooltip' do
    before { get :tooltip, id: person.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    ['mangaka', 'seyu', 'producer'].each do |kind|
      describe kind do
        let!(:person_1) { create :person, kind => true, name: 'Fffff' }
        let!(:person_2) { create :person, kind => true, name: 'zzz Ffff' }
        let!(:person_3) { create :person, name: 'Ffff' }
        before { get :autocomplete, search: 'Fff', kind: kind }

        it { expect(response).to have_http_status :success }
        it { expect(response.content_type).to eq 'application/json' }
      end
    end
  end
end
