describe ClubsController, type: :controller do
  let!(:club) do
    create :club, :with_topics, id: 999_999, is_shadowbanned: is_shadowbanned
  end
  let(:is_shadowbanned) { false }

  subject do
    get :show, params: { id: club.to_param }
  end

  context 'regular club' do
    context 'guest' do
      include_examples :has_access
    end

    context 'user' do
      include_context :authenticated, :user
      include_examples :has_access
    end
  end

  context 'shadowbanned club' do
    let(:is_shadowbanned) { true }

    context 'guest' do
      include_examples :has_no_access
    end

    context 'user' do
      include_context :authenticated, :user
      include_examples :has_no_access
    end

    context 'club member' do
      before { user.clubs << club }
      include_context :authenticated, :user
      include_examples :has_access
    end

    context 'forum/moderator/super_moderator/news_super_moderator/admin' do
      include_context :authenticated, %i[
        admin
        super_moderator
        news_super_moderator
        forum_moderator
      ].sample
      include_examples :has_access
    end
  end
end
