describe AbuseRequestsService do
  let(:service) { AbuseRequestsService.new comment, user }
  let(:user) { create :user, id: 99 }
  let(:comment) { create :comment }
  let(:faye_token) { 'test' }

  describe '#offtopic' do
    subject(:act) { service.offtopic faye_token }
    let(:comment) { create :comment, user: user }

    it { expect{act}.to_not change AbuseRequest, :count }
    it { should eq [comment.id] }

    describe 'offtopic?' do
      before { act }
      subject { comment.offtopic? }
      it { should be_truthy }
    end

    describe 'cancel' do
      context 'user' do
        context 'old comment' do
          let(:comment) { create :comment, user: user, offtopic: true, created_at: 1.month.ago }
          it { expect{act}.to change(AbuseRequest, :count).by 1 }
        end

        context 'new comment' do
          let(:comment) { create :comment, user: user, offtopic: true }
          it { expect{act}.to_not change AbuseRequest, :count }
        end
      end

      context 'moderator' do
        let(:user) { create :user, id: 1 }
        let(:comment) { create :comment, user: user, offtopic: true, created_at: 1.month.ago }
        it { expect{act}.to change(AbuseRequest, :count).by 0 }
      end
    end
  end

  describe '#review' do
    subject(:act) { service.review faye_token }
    let(:comment) { create :comment, user: user }

    it { expect{act}.to_not change AbuseRequest, :count }
    it { should eq [comment.id] }

    describe 'review?' do
      before { act }
      subject { comment.review? }
      it { should be_truthy }
    end

    describe 'cancel' do
      let(:comment) { create :comment, user: user, review: true }
      it { expect{act}.to_not change AbuseRequest, :count }
    end
  end

  [:review, :offtopic, :abuse, :spoiler].each do |method|
    describe method.to_s do
      if method == :review || method == :offtopic
        subject(:act) { service.send method, faye_token }
      else
        subject(:act) { service.send method }
      end

      let(:user) { create :user, id: 99 }
      let(:comment) { create :comment }

      it { expect{act}.to change(AbuseRequest, :count).by 1 }
      it { should eq [] }

      describe 'abuse_request' do
        before { act }
        subject { user.abuse_requests.last }
        its(:kind) { should eq method.to_s }
        its(:value) { should be_truthy }
        its(:comment_id) { should eq comment.id }
      end

      context 'abusive user' do
        let(:user) { create :user, id: AbuseRequestsService::ABUSIVE_USERS.first }
        before { act }
        subject { user.abuse_requests.last }
        it { should be_nil }
      end

      context 'already acted' do
        before { act }
        it { expect{act}.to change(AbuseRequest, :count).by 0 }
      end
    end
  end
end
