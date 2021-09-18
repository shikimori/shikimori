describe Users::ModerationsController do
  include_context :authenticated

  let(:user) { seed :user_admin }
  let(:target_user) { seed :user_day_registered }

  describe 'comments and summaries' do
    let!(:comment_1) { create :comment, user: target_user }
    let!(:comment_2) do
      create :comment,
        user: target_user,
        is_summary: true,
        body: 'x' * Comment::MIN_SUMMARY_SIZE
    end
    let!(:comment_3) { create :comment, user: user }

    context '#comments' do
      let(:make_request) { delete :comments, params: { profile_id: target_user.to_param } }

      context 'has access' do
        subject! { make_request }

        it do
          expect { comment_1.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(comment_2.reload).to be_persisted
          expect(comment_3.reload).to be_persisted
          is_expected.to redirect_to moderation_profile_url(target_user)
        end
      end

      context 'no access' do
        let(:user) { seed :user }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end

    context '#summaries' do
      let(:make_request) { delete :summaries, params: { profile_id: target_user.to_param } }

      context 'has access' do
        subject! { make_request }

        it do
          expect(comment_1.reload).to be_persisted
          expect { comment_2.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(comment_3.reload).to be_persisted
          is_expected.to redirect_to moderation_profile_url(target_user)
        end
      end

      context 'no access' do
        let(:user) { seed :user }
        it { expect { make_request }.to raise_error CanCan::AccessDenied }
      end
    end
  end

  context '#topics' do
    let!(:topic_1) { create :topic, type: nil, user: target_user }
    let!(:topic_2) { create :topic, user: target_user }
    let!(:topic_3) { create :news_topic, user: target_user }

    let!(:topic_4) { create :topic, user: user }
    let!(:critique) { create :critique, :with_topics, user: target_user }
    let!(:collection) { create :critique, :with_topics, user: target_user }

    let(:make_request) { delete :topics, params: { profile_id: target_user.to_param } }

    context 'has access' do
      subject! { make_request }

      it do
        expect { topic_1.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { topic_2.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { topic_3.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(topic_4.reload).to be_persisted
        expect(review.all_topics).to be_one
        expect(collection.all_topics).to be_one

        is_expected.to redirect_to moderation_profile_url(target_user)
      end
    end

    context 'no access' do
      let(:user) { seed :user }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end

  context '#critiques' do
    let!(:critique_1) { create :critique, user: target_user }
    let!(:critique_2) { create :critique, user: user }

    let(:make_request) { delete :critiques, params: { profile_id: target_user.to_param } }

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
