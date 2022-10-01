describe CommentsController, type: :controller do
  let!(:comment) do
    create :comment,
      commentable: commentable,
      user: user_2,
      created_at: created_at
  end
  let(:created_at) { Time.zone.now }

  subject do
    get :show, params: { id: comment.id }
  end

  context 'regular comment' do
    let(:commentable) { create :topic }

    context 'guest' do
      include_examples :has_access
    end

    context 'user' do
      include_context :authenticated, :user
      include_examples :has_access
    end
  end

  context 'club comment' do
    let(:commentable) { create :club_topic, linked: club }
    include_context :club_access_check, true

    # describe 'access to old club comment' do
    #   let(:club) { create :club }
    #
    #   context 'not expired' do
    #     include_context :authenticated, :user
    #     let(:created_at) do
    #       (Comment::AccessPolicy::CLUB_COMMENT_EXPIRATION_INTERVAL - 1.day).ago
    #     end
    #     include_examples :has_access
    #   end
    #
    #   context 'expired' do
    #     include_context :authenticated, :user
    #     let(:created_at) do
    #       (Comment::AccessPolicy::CLUB_COMMENT_EXPIRATION_INTERVAL + 1.day).ago
    #     end
    #     include_examples :has_no_access, true
    #   end
    # end
  end

  context 'club_page comment' do
    let(:commentable) { create :club_page_topic, linked: club_page }
    let(:club_page) { create :club_page, club: club }
    include_context :club_access_check, true
  end
end
