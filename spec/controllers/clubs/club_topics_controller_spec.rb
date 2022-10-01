describe Clubs::ClubTopicsController do
  include_context :authenticated, :user, :week_registered

  let(:club) { create :club, owner: user }
  let!(:club_role) { create :club_role, club: club, user: user }
  let(:topic) { create :club_user_topic, linked: club }

  let(:topic_params) do
    {
      user_id: user.id,
      forum_id: clubs_forum.id,
      title: topic_title,
      body: 'text',
      linked_id: club.id,
      linked_type: Club.name,
      type: Topics::ClubUserTopic.name
    }
  end
  let(:topic_title) { 'title' }

  describe '#index' do
    before { get :index, params: { club_id: club_id } }

    context 'valid path' do
      let(:club_id) { club.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'invalid path' do
      let(:club_id) { club.id }
      it do
        expect(response).to redirect_to club_club_topics_url(club)
      end
    end
  end

  describe '#show' do
    before { get :show, params: { club_id: club.to_param, id: topic_id } }

    context 'valid path' do
      let(:topic_id) { topic.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'invalid path' do
      let(:topic_id) { topic.id }
      it do
        expect(response).to redirect_to UrlGenerator.instance.topic_url(topic)
      end
    end
  end

  describe '#new' do
    before do
      get :new,
        params: {
          club_id: club.id,
          topic: topic_params
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    before do
      post :create,
        params: {
          club_id: club.id,
          topic: topic_params
        }
    end

    context 'valid params' do
      it do
        expect(resource).to have_attributes topic_params
        expect(response).to redirect_to UrlGenerator.instance.topic_url(resource)
      end
    end

    context 'invalid params' do
      let(:topic_title) { nil }
      it do
        expect(resource).to_not be_valid
        expect(response).to have_http_status :success
      end
    end
  end
end
