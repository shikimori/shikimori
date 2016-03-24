describe AbuseRequest do
  describe 'relations' do
    it { should belong_to :comment }
    it { should belong_to :user }
    it { should belong_to :approver }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :comment }

    context 'accepted' do
      subject { build :abuse_request, state: 'accepted' }
      it { should validate_presence_of :approver }
    end

    context 'rejected' do
      subject { build :abuse_request, state: 'rejected' }
      it { should validate_presence_of :approver }
    end
  end

  context 'scopes' do
    let(:user) { create :user }
    let(:comment) { create :comment, user: user }

    describe 'pending' do
      let!(:offtop) { create :abuse_request, kind: :offtopic, comment: comment }
      let!(:abuse) { create :abuse_request, kind: :abuse, comment: comment }
      let!(:accepted) { create :accepted_abuse_request, kind: :offtopic, approver: user }

      it { expect(AbuseRequest.pending).to eq [offtop] }
    end

    describe 'abuses' do
      let!(:offtop) { create :abuse_request, kind: :offtopic, comment: comment }
      let!(:abuse) { create :abuse_request, kind: :abuse, comment: comment }

      it { expect(AbuseRequest.abuses).to eq [abuse] }
    end
  end

  context 'state_machine' do
    let(:user) { create :user }
    subject(:abuse_request) { create :abuse_request, user: user }

    describe '#take' do
      before { abuse_request.take user }
      its(:approver) { should eq user }

      context 'comment' do
        subject { abuse_request.comment }
        its(:is_offtopic) { should be_truthy }
      end
    end

    describe '#reject' do
      before { abuse_request.reject user }
      its(:approver) { should eq user }

      context 'comment' do
        subject { abuse_request.comment }
        its(:is_offtopic) { should be_falsy }
      end
    end
  end

  describe 'instance methods' do
    describe '#reason=' do
      let(:abuse_request) { build :abuse_request, reason: 'a' * 3000 }
      it { expect(abuse_request.reason).to have(AbuseRequest::MAXIMUM_REASON_SIZE).items }
    end

    describe '#punishable?' do
      let(:abuse_request) { build :abuse_request, kind: kind }
      subject { abuse_request.punishable? }

      describe true do
        context 'abuse' do
          let(:kind) { 'abuse' }
          it { should be_truthy }
        end

        context 'spoiler' do
          let(:kind) { 'spoiler' }
          it { should be_truthy }
        end
      end

      describe false do
        context 'offtopic' do
          let(:kind) { 'offtopic' }
          it { should be_falsy }
        end

        context 'summary' do
          let(:kind) { 'summary' }
          it { should be_falsy }
        end
      end
    end
  end

  context 'class methods' do
    describe '#has_changes?' do
      let(:user) { create :user }
      subject { AbuseRequest.has_changes? }

      describe 'true' do
        before { allow(AbuseRequest).to receive_message_chain(:pending, :count).and_return 1 }
        it { should be_truthy }
      end

      describe 'false' do
        before { allow(AbuseRequest).to receive_message_chain(:pending, :count).and_return 0 }
        it { should be_falsy }
      end
    end

    describe '#has_abuses?' do
      let(:user) { create :user }
      subject { AbuseRequest.has_abuses? }

      describe 'true' do
        before { allow(AbuseRequest).to receive_message_chain(:abuses, :count).and_return 1 }
        it { should be_truthy }
      end

      describe 'false' do
        before { allow(AbuseRequest).to receive_message_chain(:abuses, :count).and_return 0 }
        it { should be_falsy }
      end
    end
  end
end
