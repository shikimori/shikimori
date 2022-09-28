describe ModerationPolicy do
  let(:policy) { ModerationPolicy.new user, moderation_filter }
  let(:moderation_filter) { true }

  describe '#critiques_count' do
    before do
      allow(Critique)
        .to receive_message_chain(:pending, :size)
        .and_return(critiques_count)
    end
    let(:critiques_count) { 1 }
    let(:user) { build :user, :critique_moderator }

    it { expect(policy.critiques_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.critiques_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.critiques_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.critiques_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.critiques_count).to eq 1 }
      end
    end
  end

  describe '#collections_count' do
    before do
      allow(Collection)
        .to receive_message_chain(:pending, :published, :size)
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

  describe '#news_count' do
    before do
      allow(Topics::NewsTopic)
        .to receive_message_chain(:pending, :size)
        .and_return(news_count)
    end
    let(:news_count) { 1 }
    let(:user) { build :user, :news_moderator }

    it { expect(policy.news_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.news_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.news_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.news_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.news_count).to eq 1 }
      end
    end
  end

  describe '#articles_count' do
    before do
      allow(Article)
        .to receive_message_chain(:pending, :size)
        .and_return(articles_count)
    end
    let(:articles_count) { 1 }
    let(:user) { build :user, :article_moderator }

    it { expect(policy.articles_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.articles_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.articles_count).to eq 0 }
    end

    context 'no moderation filter' do
      let(:moderation_filter) { false }

      context 'not moderator' do
        let(:user) { build :user, :user }
        it { expect(policy.articles_count).to eq 1 }
      end

      context 'no user' do
        let(:user) { nil }
        it { expect(policy.articles_count).to eq 1 }
      end
    end
  end

  describe '#abuse_requests_total_count, #abuse_requests_bannable_count, #abuse_requests_not_bannable_count' do
    before do
      allow(AbuseRequest)
        .to receive_message_chain(:pending, :bannable, :size)
        .and_return(abuse_requests_bannable_count)

      allow(AbuseRequest)
        .to receive_message_chain(:pending, :not_bannable, :size)
        .and_return(abuse_requests_not_bannable_count)
    end
    let(:abuse_requests_bannable_count) { 1 }
    let(:abuse_requests_not_bannable_count) { 2 }
    let(:user) { build :user, :forum_moderator }

    it do
      expect(policy.abuse_requests_total_count).to eq 3
      expect(policy.abuse_requests_bannable_count).to eq 1
      expect(policy.abuse_requests_not_bannable_count).to eq 2
    end

    context 'not moderator' do
      let(:user) { build :user, :user }
      it do
        expect(policy.abuse_requests_total_count).to eq 0
        expect(policy.abuse_requests_bannable_count).to eq 0
        expect(policy.abuse_requests_not_bannable_count).to eq 0
      end
    end

    context 'no user' do
      let(:user) { nil }
      it do
        expect(policy.abuse_requests_total_count).to eq 0
        expect(policy.abuse_requests_bannable_count).to eq 0
        expect(policy.abuse_requests_not_bannable_count).to eq 0
      end
    end
  end

  describe '#all_content_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:fetch, :pending, :size)
        .and_return(versions_count)
    end
    let(:versions_count) { 1 }
    let(:user) { build :user, :version_moderator }

    it { expect(policy.all_content_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.all_content_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.all_content_versions_count).to eq 0 }
    end
  end

  describe '#texts_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:fetch, :pending, :size)
        .and_return(versions_count)
    end
    let(:versions_count) { 1 }
    let(:user) { build :user, :version_texts_moderator }

    it { expect(policy.texts_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.texts_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.texts_versions_count).to eq 0 }
    end
  end

  describe '#content_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:fetch, :pending, :size)
        .and_return(content_versions_count)
    end
    let(:content_versions_count) { 1 }
    let(:user) { build :user, :version_moderator }

    it { expect(policy.content_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.content_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.content_versions_count).to eq 0 }
    end
  end

  describe '#fansub_versions_count' do
    before do
      allow(Moderation::VersionsItemTypeQuery)
        .to receive_message_chain(:fetch, :pending, :size)
        .and_return(fansub_versions_count)
    end
    let(:fansub_versions_count) { 1 }
    let(:user) { build :user, :version_fansub_moderator }

    it { expect(policy.fansub_versions_count).to eq 1 }

    context 'not moderator' do
      let(:user) { build :user, :user }
      it { expect(policy.fansub_versions_count).to eq 0 }
    end

    context 'no user' do
      let(:user) { nil }
      it { expect(policy.fansub_versions_count).to eq 0 }
    end
  end
end
