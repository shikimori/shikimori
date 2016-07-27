# frozen_string_literal: true

describe Topic::TypePolicy do
  let(:policy) { Topic::TypePolicy.new topic }

  let(:forum_topic) { build_stubbed :forum_topic }
  let(:news_topic) { build_stubbed :news_topic }
  let(:generated_news_topic) { build_stubbed :news_topic, generated: true }
  let(:review_topic) { build_stubbed :review_topic }
  let(:cosplay_gallery_topic) { build_stubbed :cosplay_gallery_topic }
  let(:contest_topic) { build_stubbed :contest_topic }

  describe '#forum_topic?' do
    subject { policy.forum_topic? }

    context 'forum topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq true }
    end

    context 'not forum topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#news_topic?' do
    subject { policy.news_topic? }

    context 'news topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq true }
    end

    context 'not news topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#generated_news_topic?' do
    subject { policy.generated_news_topic? }

    context 'generated news topic' do
      let(:topic) { generated_news_topic }
      it { is_expected.to eq true }
    end

    context 'not generated news topic' do
      let(:topic) { news_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#review_topic?' do
    subject { policy.review_topic? }

    context 'review topic' do
      let(:topic) { review_topic }
      it { is_expected.to eq true }
    end

    context 'not review topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#cosplay_gallery_topic?' do
    subject { policy.cosplay_gallery_topic? }

    context 'cosplay gallery topic' do
      let(:topic) { cosplay_gallery_topic }
      it { is_expected.to eq true }
    end

    context 'not cospaly gallery topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end

  describe '#contest_topic?' do
    subject { policy.contest_topic? }

    context 'contest topic' do
      let(:topic) { contest_topic }
      it { is_expected.to eq true }
    end

    context 'not contest topic' do
      let(:topic) { forum_topic }
      it { is_expected.to eq false }
    end
  end
end
