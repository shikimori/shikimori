describe Clubs::ClubTopicsController do
  include_context :seeds

  before { sign_in user }

  let(:user) { create :user, :user, :week_registered }
  let(:club) { create :club, owner: user }
  let!(:club_role) { create :club_role, club: club, user: user }

  let(:topic_params) do
    {
      user_id: user.id,
      forum_id: clubs_forum.id,
      title: 'title',
      body: 'text',
      linked_id: club.id,
      linked_type: Club.name,
      type: 'Topics::ClubUserTopic'
    }
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

  # describe '#create' do
    # before do
      # post :create,
        # params: {
          # club_id: club.id,
          # topic: topic_params
        # }
    # end

    # context 'valid params', :focus do
      # it do
        # expect(resource).to have_attributes topic_params
        # expect(resource.locale).to eq controller.locale_from_host.to_s
        # expect(response).to redirect_to UrlGenerator.instance.topic_url(resource)
      # end
    # end

    # context 'invalid params' do
      # let(:params) do
        # {
          # user_id: user.id,
          # type: Topic.name,
          # forum_id: clubs_forum.id,
          # title: ''
        # }
      # end

      # it do
        # expect(assigns(:topic)).to_not be_valid
        # expect(response).to have_http_status :success
      # end
    # end
  # end
end
