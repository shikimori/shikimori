describe Api::V1::UsersController, :show_in_doc do
  let(:user) { create :user, nickname: 'Test' }

  describe '#index' do
    let!(:user_1) { create :user, nickname: 'Test1' }
    let!(:user_2) { create :user, nickname: 'Test2' }
    let!(:user_3) { create :user, nickname: 'Test3' }

    let(:phrase) { 'Te' }
    before do
      allow(Elasticsearch::Query::User).to receive(:call).with(
        phrase: phrase,
        limit: Collections::Query::SEARCH_LIMIT
      ).and_return(
        user_1.id => 1.23,
        user_2.id => 1.11
      )
    end

    subject! do
      get :index,
        params: {
          page: 1,
          limit: 1,
          search: phrase
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to eq [user_1, user_2]
    end
  end

  describe '#show' do
    subject! { get :show, params: { id: user.id }, format: :json }

    it do
      expect(json).to_not have_key :email
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#info' do
    subject! { get :info, params: { id: user.id }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
    end
  end

  describe '#whoami' do
    describe 'signed in' do
      before { sign_in user }
      subject! { get :whoami, format: :json }

      it do
        expect(json).to be_a Hash
        expect(json[:id]).to eq user.id
        expect(json[:nickname]).to eq user.nickname
        expect(response).to have_http_status :success
      end
    end

    unless ENV['APIPIE_RECORD']
      describe 'guest' do
        subject! { get :whoami, format: :json }
        specify { expect(response.body).to eq 'null' }
      end
    end
  end

  describe '#sign_out' do
    describe 'signed in' do
      before { sign_in user }
      subject! { get :sign_out }

      it do
        expect(controller.current_user).to be_nil
        expect(response).to have_http_status :success
      end
    end

    unless ENV['APIPIE_RECORD']
      describe 'guest' do
        subject! { get :sign_out }
        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#friends' do
    let!(:friend_link) { create :friend_link, src: user, dst: create(:user) }
    subject! { get :friends, params: { id: user.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#anime_rates' do
    let(:user) { create :user }
    let(:anime) { create :anime }
    let!(:user_rate) { create :user_rate, target: anime, user: user, status: 'completed' }

    subject! do
      get :anime_rates,
        params: {
          id: user.id,
          status: 'completed',
          limit: 250,
          page: 1
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(assigns(:rates)).to have(1).item
    end
  end

  describe '#manga_rates' do
    let(:manga) { create :manga }
    let!(:user_rate) { create :user_rate, target: manga, user: user, status: 1 }
    subject! do
      get :manga_rates,
        params: {
          id: user.id,
          status: 1,
          limit: 250,
          page: 1
        },
        format: :json
    end

    it do
      expect(response).to have_http_status :success
      expect(assigns(:rates)).to have(1).item
    end
  end

  describe '#clubs' do
    let(:user) { create :user, clubs: [create(:club)] }
    subject! { get :clubs, params: { id: user.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#favourites' do
    let(:anime) { create :anime }
    let(:manga) { create :manga }
    let(:character) { create :character }
    let(:person) { create :person }
    let!(:fav_anime) { create :favourite, linked: anime }
    let!(:fav_manga) { create :favourite, linked: manga }
    let!(:fav_character) { create :favourite, linked: character }
    let!(:fav_person) do
      create :favourite, linked: person, kind: Types::Favourite::Kind[:person]
    end
    let!(:fav_mangaka) do
      create :favourite, linked: person, kind: Types::Favourite::Kind[:mangaka]
    end
    let!(:fav_producer) do
      create :favourite, linked: person, kind: Types::Favourite::Kind[:producer]
    end
    let!(:fav_seyu) do
      create :favourite, linked: person, kind: Types::Favourite::Kind[:seyu]
    end

    subject! { get :favourites, params: { id: user.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#messages' do
    let(:user_2) { create :user }
    let(:topic) { create :news_topic, linked: create(:anime), action: 'episode' }
    let!(:news) { create :message, kind: MessageType::ANONS, to: user, from: user_2, body: 'anime [b]anons[/b]', linked: topic }

    context 'signed_in' do
      before { sign_in user }
      subject! { get :messages, params: { id: user.id, page: 1, limit: 20, type: 'news' }, format: :json }

      it { expect(response).to have_http_status :success }
    end

    unless ENV['APIPIE_RECORD']
      context 'guest' do
        subject! do
          get :messages,
            params: {
              id: user.id,
              page: 1,
              limit: 20,
              type: 'news'
            },
            format: :json
        end

        it { expect(response).to have_http_status 401 }
      end
    end
  end

  describe '#unread_messages' do
    context 'signed_in' do
      before { sign_in user }
      subject! { get :unread_messages, params: { id: user.id }, format: :json }

      it { expect(response).to have_http_status :success }
    end

    unless ENV['APIPIE_RECORD']
      context 'guest' do
        subject! { get :unread_messages, params: { id: user.id }, format: :json }
        it { expect(response).to have_http_status 401 }
      end
    end
  end

  describe '#history' do
    let!(:entry_1) { create :user_history, user: user, action: 'mal_anime_import', value: '522' }
    let!(:entry_2) { create :user_history, anime: create(:anime), user: user, action: 'status' }

    subject! do
      get :history,
        params: {
          id: user.id,
          limit: 10,
          page: 1,
          updated_at_gte: 1.hour.ago.strftime('%Y-%m-%d %H:%M:%S'),
          updated_at_lte: 1.hour.from_now.strftime('%Y-%m-%d %H:%M:%S')
        },
        format: :json
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#bans' do
    let!(:ban) do
      create :ban,
        user: user,
        moderator: user,
        comment: create(:comment, user: user)
    end
    subject! { get :bans, params: { id: user.id }, format: :json }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
    end
  end
end
