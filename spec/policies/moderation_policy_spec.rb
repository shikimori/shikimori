describe ModerationPolicy do
  let(:policy) { ModerationPolicy.new user, :ru, moderation_filter }
  let(:moderation_filter) { true }

  describe '#reviews_count' do
    before do
      allow(Review)
        .to receive_message_chain(:pending, :where, :size)
        .and_return(reviews_count)
    end
    let(:reviews_count) { 1 }
    let(:user) { build :user, :review_moderator }

    it { expect(policy.reviews_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.reviews_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.reviews_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.reviews_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.reviews_count).to eq 1 }
      end
    end
  end

  describe '#collections_count' do
    before do
      allow(Collection)
        .to receive_message_chain(:pending, :published, :where, :size)
        .and_return(collections_count)
    end
    let(:collections_count) { 1 }
    let(:user) { build :user, :collection_moderator }

    it { expect(policy.collections_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.collections_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.collections_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.collections_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.collections_count).to eq 1 }
      end
    end
  end

  describe '#abuses_count' do
    before do
      allow(AbuseRequest)
        .to receive_message_chain(:abuses, :size)
        .and_return(abuse_abuses_count)

      allow(AbuseRequest)
        .to receive_message_chain(:pending, :size)
        .and_return(abuse_pending_count)
    end
    let(:abuse_abuses_count) { 1 }
    let(:abuse_pending_count) { 2 }
    let(:user) { build :user, :forum_moderator }

    it { expect(policy.abuses_count).to eq 3 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.abuses_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.abuses_count).to eq 0 }
    end
  end

  describe '#content_count' do
    before do
      allow(Version)
        .to receive_message_chain(:pending_content, :size)
        .and_return(content_count)
    end
    let(:content_count) { 1 }
    let(:user) { build :user, :version_moderator }

    it { expect(policy.content_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.content_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.content_count).to eq 0 }
    end
  end

  describe '#videos_count' do
    before do
      allow(Version)
        .to receive_message_chain(:pending_videos, :size)
        .and_return(videos_count)
    end
    let(:videos_count) { 1 }
    let(:user) { build :user, :video_moderator }

    it { expect(policy.videos_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.videos_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.videos_count).to eq 0 }
    end
  end
end
