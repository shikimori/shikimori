describe AbuseRequestsService do
  let(:service) { AbuseRequestsService.new comment, user }
  let(:user) { create :user, id: 99 }
  let(:comment) { create :comment }

  describe :offtopic do
    subject(:act) { service.offtopic }
    let(:comment) { create :comment, user: user }

    it { expect{act}.to_not change AbuseRequest, :count }
    it { should eq [comment.id] }

    describe :offtopic? do
      before { act }
      subject { comment.offtopic? }
      it { should be_true }
    end

    describe :cancel do
      context :common_user do
        context :old_comment do
          let(:comment) { create :comment, user: user, offtopic: true, created_at: 1.month.ago }
          it { expect{act}.to change(AbuseRequest, :count).by 1 }
        end

        context :new_comment do
          let(:comment) { create :comment, user: user, offtopic: true }
          it { expect{act}.to_not change AbuseRequest, :count }
        end
      end

      context :moderator_user do
        let(:user) { create :user, id: 1 }
        let(:comment) { create :comment, user: user, offtopic: true, created_at: 1.month.ago }
        it { expect{act}.to change(AbuseRequest, :count).by 0 }
      end
    end
  end

  describe :review do
    subject(:act) { service.review }
    let(:comment) { create :comment, user: user }

    it { expect{act}.to_not change AbuseRequest, :count }
    it { should eq [comment.id] }

    describe :review? do
      before { act }
      subject { comment.review? }
      it { should be_true }
    end

    describe :cancel do
      let(:comment) { create :comment, user: user, review: true }
      it { expect{act}.to_not change AbuseRequest, :count }
    end
  end

  [:review, :offtopic, :abuse, :spoiler].each do |method|
    describe method do
      subject(:act) { service.send method }
      let(:user) { create :user, id: 99 }
      let(:comment) { create :comment }

      it { expect{act}.to change(AbuseRequest, :count).by 1 }
      it { should eq [] }

      describe :abuse_request do
        before { act }
        subject { user.abuse_requests.last }
        its(:kind) { should eq method.to_s }
        its(:value) { should be_true }
        its(:comment_id) { should eq comment.id }
      end

      context :abusive_user do
        let(:user) { create :user, id: AbuseRequestsService::ABUSIVE_USERS.first }
        before { act }
        subject { user.abuse_requests.last }
        it { should be_nil }
      end

      context :already_acted do
        before { act }
        it { expect{act}.to change(AbuseRequest, :count).by 0 }
      end
    end
  end
end
