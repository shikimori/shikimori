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
    subject! { get :index, params: { search: 'Fff', kind: kind } }

    it do
      expect(collection).to eq [person]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let!(:person) { create :person, :with_topics, mangaka: true }
    subject! { get :show, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#works' do
    let!(:manga) { create :manga }
    let!(:person_role) { create :person_role, person: person, roles: %w[Director] }
    subject! { get :works, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#roles' do
    let!(:character) { create :character }
    let!(:person_role) { create :person_role, person: person, roles: %w[Seyu] }
    subject! { get :roles, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#favoured' do
    let!(:favoured) { create :favourite, linked: person, kind: :person }
    subject! { get :favoured, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#collections' do
    let!(:collection) { create :collection, :published, :with_topics, :person }
    let!(:collection_link) do
      create :collection_link, collection: collection, linked: person
    end
    subject! { get :collections, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#tooltip' do
    subject! { get :tooltip, params: { id: person.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#autocomplete' do
    let(:person) { build_stubbed :person }
    let(:phrase) { 'qqq' }
    let(:kind) { 'mangaka' }

    before { allow(Autocomplete::Person).to receive(:call).and_return [person] }
    subject! { get :autocomplete, params: { search: 'Fff', kind: kind }, xhr: true }

    it do
      expect(collection).to eq [person]
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#autocomplete_v2' do
    let(:entry) { create :person }
    let(:phrase) { 'qqq' }

    before do
      allow(Autocomplete::Person)
        .to receive(:call)
        .and_return Person.where(id: entry.id)
    end
    subject! { get :autocomplete_v2, params: { search: 'Fff' }, xhr: true }

    it do
      expect(collection).to eq [entry]
      expect(response.content_type).to eq 'text/html; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end
end
