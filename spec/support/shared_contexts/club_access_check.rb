shared_context :club_access_check do |is_nil_object_when_no_access|
  let(:club) do
    create :club, :with_topics,
      is_shadowbanned: is_shadowbanned,
      is_private: is_private
  end
  let(:is_shadowbanned) { false }
  let(:is_private) { false }

  moderators_role = %i[
    admin
    super_moderator
    news_super_moderator
    forum_moderator
  ].sample

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
      include_examples :has_no_access, is_nil_object_when_no_access
    end

    context 'user' do
      include_context :authenticated, :user
      include_examples :has_no_access, is_nil_object_when_no_access
    end

    context 'club member' do
      before { user.clubs << club }
      include_context :authenticated, :user
      include_examples :has_access
    end

    context 'moderators' do
      include_context :authenticated, moderators_role
      include_examples :has_access
    end
  end

  context 'private club' do
    let(:is_private) { true }

    context 'guest' do
      include_examples :has_no_access, is_nil_object_when_no_access
    end

    context 'user' do
      include_context :authenticated, :user
      include_examples :has_no_access, is_nil_object_when_no_access
    end

    context 'club member' do
      before { user.clubs << club }
      include_context :authenticated, :user
      include_examples :has_access
    end

    context 'moderators' do
      include_context :authenticated, moderators_role
      include_examples :has_access
    end
  end
end
