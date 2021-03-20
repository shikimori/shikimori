describe Api::V1::RanobeController, :show_in_doc do
  describe '#index' do
    include_context :authenticated, :user

    let(:genre) { create :genre }
    let(:publisher) { create :publisher }
    let!(:user_rate) { create :user_rate, target: ranobe, user: user, status: 1 }
    let(:ranobe) do
      create :ranobe,
        name: 'Test',
        aired_on: Date.parse('2014-01-01'),
        publisher_ids: [publisher.id],
        genre_ids: [genre.id],
        franchise: 'zxc'
    end

    before do
      allow(Search::Ranobe).to receive(:call) { |params| params[:scope] }
    end

    subject! do
      get :index,
        params: {
          page: 1,
          limit: 1,
          season: '2014',
          genre: genre.id.to_s,
          publisher: publisher.id.to_s,
          franchise: 'zxc',
          search: 'Te',
          order: 'ranked',
          mylist: '1',
          censored: 'false'
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#show' do
    let(:ranobe) { create :ranobe, :with_topics }
    subject! { get :show, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#similar' do
    let(:ranobe) { create :ranobe }
    let!(:similar) { create :similar_manga, src: ranobe }
    subject! { get :similar, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#roles' do
    let(:ranobe) { create :ranobe }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:role_1) { create :person_role, manga: ranobe, character: character, roles: %w[Main] }
    let!(:role_2) { create :person_role, manga: ranobe, person: person, roles: %w[Director] }

    subject! { get :roles, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(2).items
    end
  end

  describe '#related' do
    let(:ranobe) { create :ranobe }
    let!(:similar) { create :related_manga, source: ranobe, manga: create(:ranobe), relation: 'Adaptation' }

    subject! { get :related, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
      expect(collection).to have(1).item
    end
  end

  describe '#franchise' do
    before { Animes::BannedRelations.instance.clear_cache! }
    after(:all) { Animes::BannedRelations.instance.clear_cache! }

    let(:ranobe) { create :ranobe }
    let!(:similar) { create :related_manga, source: ranobe, manga: create(:ranobe), relation: 'Adaptation' }

    subject! { get :franchise, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#external_links' do
    let(:ranobe) { create :ranobe, mal_id: 123 }
    let!(:external_links) do
      create :external_link,
        entry: ranobe,
        kind: :wikipedia,
        url: 'en.wikipedia.org'
    end

    subject! { get :external_links, params: { id: ranobe.id }, format: :json }

    it do
      expect(collection).to have(2).items
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end

  describe '#topics' do
    let!(:topic) { create :topic, linked: ranobe, locale: 'ru' }
    let(:ranobe) { create :ranobe }

    subject! { get :topics, params: { id: ranobe.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(collection).to have(1).item
      expect(response.content_type).to eq 'application/json'
    end
  end
end
