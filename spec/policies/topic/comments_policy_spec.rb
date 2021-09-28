# frozen_string_literal: true

describe Topic::CommentsPolicy do
  let(:policy) { Topic::CommentsPolicy.new topic }

  let(:topic) { create :anime_topic, comments_count: comments_count, linked: anime }
  let(:comments_count) { 0 }

  describe '#comments_count' do
    subject { policy.comments_count }
    let(:comments_count) { 2 }

    it { is_expected.to eq 2 }
  end

  describe '#summaries_count' do
    subject { policy.summaries_count }
    before do
      create :comment, :summary, topic: topic
      create :comment, :summary, topic: topic
      create :comment, topic: topic
    end

    it { is_expected.to eq 2 }
  end

  describe '#any_comments?' do
    subject { policy.any_comments? }

    context 'comments count > 0' do
      let(:comments_count) { 1 }
      it { is_expected.to eq true }
    end

    context 'comments count == 0' do
      let(:comments_count) { 0 }
      it { is_expected.to eq false }
    end
  end

  describe '#any_summaries?' do
    subject { policy.any_summaries? }

    let(:summaries_count) { 0 }
    before do
      allow(policy)
        .to receive(:summaries_count)
        .and_return summaries_count
    end

    context 'summaries count > 0' do
      let(:summaries_count) { 1 }
      it { is_expected.to eq true }
    end

    context 'summaries count == 0' do
      let(:summaries_count) { 0 }
      it { is_expected.to eq false }
    end
  end

  describe '#all_summaries?' do
    subject { policy.all_summaries? }

    let(:summaries_count) { 0 }
    before do
      allow(policy)
        .to receive(:summaries_count)
        .and_return summaries_count
    end

    context 'all comments are summaries' do
      let(:comments_count) { 1 }
      let(:summaries_count) { 1 }
      it { is_expected.to eq true }
    end

    context 'not all comments are summaries' do
      let(:comments_count) { 2 }
      let(:summaries_count) { 1 }
      it { is_expected.to eq false }
    end
  end
end
