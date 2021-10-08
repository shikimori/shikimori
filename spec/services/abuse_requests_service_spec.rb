describe AbuseRequestsService do
  let(:service) do
    AbuseRequestsService.new(
      comment: comment,
      topic: topic,
      review: review,
      reporter: reporter
    )
  end
  let!(:reporter) { create :user, id: 99 }

  let(:comment) do
    create :comment, :skip_cancel_summary,
      user: comment_user,
      is_offtopic: is_offtopic,
      is_summary: is_summary,
      created_at: created_at
  end
  let(:is_offtopic) { false }
  let(:is_summary) { false }
  let(:created_at) { Time.zone.now }
  let(:comment_user) { seed :user }
  let(:reporter) { comment_user }

  let(:topic) { nil }
  let(:review) { nil }

  let(:faye_token) { 'test' }

  describe '#offtopic' do
    subject(:act) { service.offtopic faye_token }

    it do
      expect { act }.to_not change AbuseRequest, :count
      is_expected.to eq [comment.id]
    end

    describe 'offtopic?' do
      before { act }
      subject { comment.offtopic? }
      it { is_expected.to eq true }
    end

    describe 'cancel' do
      let(:is_offtopic) { true }

      context 'user' do
        context 'old comment' do
          let(:created_at) { 1.month.ago }
          it { expect { act }.to change(AbuseRequest, :count).by 1 }
        end

        context 'new comment' do
          it { expect { act }.to_not change AbuseRequest, :count }
        end
      end

      context 'moderator' do
        let(:created_at) { 1.month.ago }
        let(:reporter) { create :user, :forum_moderator }
        it { expect { act }.to change(AbuseRequest, :count).by 0 }
      end
    end
  end

  describe '#summary' do
    subject(:act) { service.summary faye_token }

    context 'new comment' do
      let(:created_at) { 4.minutes.ago }

      it do
        expect { act }.to_not change AbuseRequest, :count
        is_expected.to eq [comment.id]
        expect(comment).to be_summary
      end

      describe 'cancel' do
        let(:is_summary) { true }

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
      if %i[summary offtopic].include? method # rubocop:disable CollectionLiteralInLoop
        let(:reason) { nil }
        subject(:act) { service.send method, faye_token }
      else
        let(:reason) { 'zxcvbn' }
        subject(:act) { service.send method, reason }
      end
      let(:reporter) { create :user, id: 99 }

      it do
        expect { act }.to change(AbuseRequest, :count).by 1
        is_expected.to eq []
      end

      describe 'abuse_request' do
        before { act }
        subject { reporter.abuse_requests.last }

        it do
          expect(subject).to have_attributes(
            kind: method.to_s,
            value: true,
            comment_id: comment.id,
            reason: reason
          )
        end
      end

      context 'already acted' do
        before { act }
        it { expect { act }.to change(AbuseRequest, :count).by 0 }
      end
    end
  end
end
