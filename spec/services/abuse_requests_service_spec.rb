describe AbuseRequestsService do
  let(:service) { AbuseRequestsService.new comment, user }
  let!(:user) { create :user, id: 99 }
  let(:comment) { create :comment }
  let(:faye_token) { 'test' }

  describe '#offtopic' do
    subject(:act) { service.offtopic faye_token }
    let(:comment) { create :comment, user: user }

    it { expect { act }.to_not change AbuseRequest, :count }
    it { is_expected.to eq [comment.id] }

    describe 'offtopic?' do
      before { act }
      subject { comment.offtopic? }
      it { is_expected.to eq true }
    end

    describe 'cancel' do
      context 'user' do
        context 'old comment' do
          let(:comment) { create :comment, :offtopic, user: user, created_at: 1.month.ago }
          it { expect { act }.to change(AbuseRequest, :count).by 1 }
        end

        context 'new comment' do
          let(:comment) { create :comment, :offtopic, user: user }
          it { expect { act }.to_not change AbuseRequest, :count }
        end
      end

      context 'moderator' do
        let(:user) { create :user, :forum_moderator }
        let(:comment) { create :comment, :offtopic, user: user, created_at: 1.month.ago }
        it { expect { act }.to change(AbuseRequest, :count).by 0 }
      end
    end
  end

  describe '#summary' do
    subject(:act) { service.summary faye_token }
    let(:comment) { create :comment, user: user, created_at: created_at }

    context 'new comment' do
      let(:created_at) { 4.minutes.ago }

      it do
        expect { act }.to_not change AbuseRequest, :count
        is_expected.to eq [comment.id]
        expect(comment).to be_summary
      end

      describe 'cancel' do
        let(:comment) { create :comment, :summary, :skip_cancel_summary, user: user }

        it do
          expect { act }.to_not change AbuseRequest, :count
          is_expected.to eq [comment.id]
          expect(comment).not_to be_summary
        end
      end
    end

    context 'old comment' do
      let(:created_at) { 6.minutes.ago }
      it do
        expect { act }.to change AbuseRequest, :count
        is_expected.to eq []
        expect(comment).to_not be_summary
      end
    end
  end

  %i[summary offtopic abuse spoiler].each do |method|
    describe method.to_s do
      if %i[summary offtopic].include? method
        let(:reason) { nil }
        subject(:act) { service.send method, faye_token }
      else
        let(:reason) { 'zxcvbn' }
        subject(:act) { service.send method, reason }
      end

      let(:user) { create :user, id: 99 }
      let(:comment) { create :comment }

      it { expect { act }.to change(AbuseRequest, :count).by 1 }
      it { is_expected.to eq [] }

      describe 'abuse_request' do
        before { act }
        subject { user.abuse_requests.last }

        it { expect(subject).to have_attributes kind: method.to_s, value: true, comment_id: comment.id, reason: reason }
      end

      context 'already acted' do
        before { act }
        it { expect { act }.to change(AbuseRequest, :count).by 0 }
      end
    end
  end
end
