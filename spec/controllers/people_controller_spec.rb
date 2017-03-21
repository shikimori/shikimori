describe PeopleController do
  let!(:person) { create :person }

  describe '#index' do
    let(:phrase) { 'qqq' }
    let(:kind) { 'mangaka' }

    before do
      allow(Search::Person)
        .to receive(:call)
        .and_return Person.where(id: person.id)
    end
    before { get :index, params: { search: 'Fff', kind: kind } }

    it do
      expect(collection).to eq [person]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let!(:person) { create :person, :with_topics, mangaka: true }
    before { get :show, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#works' do
    let!(:manga) { create :manga, person_roles: [create(:person_role, person: person, role: 'Director')] }
    before { get :works, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: person }
    before { get :favoured, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#tooltip' do
    before { get :tooltip, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let(:person) { build_stubbed :person }
    let(:phrase) { 'qqq' }
    let(:kind) { 'mangaka' }

    before { allow(Autocomplete::Person).to receive(:call).and_return [person] }
    before { get :autocomplete, params: { search: 'Fff', kind: kind } }

    it do
      expect(collection).to eq [person]
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end
end
