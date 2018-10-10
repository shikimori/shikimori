describe Users::ModerationsController do
  include_context :authenticated

  let(:user) { seed :user_admin }
  let(:target_user) { seed :user_day_registered }

  context '#comments' do
    let!(:comment_1) { create :comment, user: target_user }
    let!(:comment_2) { create :comment, user: user }

    let(:make_request) { delete :comments, params: { profile_id: target_user.to_param } }

    context 'has access' do
      subject! { make_request }

      it do
        expect { comment_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(comment_2.reload).to be_persisted
        is_expected.to redirect_to moderation_profile_url(target_user)
      end
    end

    context 'no access' do
      let(:user) { seed :user }

      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  context '#topics' do
    let!(:topic_1) { create :topic, user: target_user }
    let!(:topic_2) { create :topic, user: user }

    let(:make_request) { delete :topics, params: { profile_id: target_user.to_param } }

    context 'has access' do
      subject! { make_request }

      it do
        expect { topic_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(topic_2.reload).to be_persisted
        is_expected.to redirect_to moderation_profile_url(target_user)
      end
    end

    context 'no access' do
      let(:user) { seed :user }

      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  context '#reviews' do
    let!(:review_1) { create :review, user: target_user }
    let!(:review_2) { create :review, user: user }

    let(:make_request) { delete :reviews, params: { profile_id: target_user.to_param } }

    context 'has access' do
      subject! { make_request }

      it do
        expect { review_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(review_2.reload).to be_persisted
        is_expected.to redirect_to moderation_profile_url(target_user)
      end
    end

    context 'no access' do
      let(:user) { seed :user }

      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
