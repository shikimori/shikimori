# frozen_string_literal: true

describe Topics::Generate::News::ReleaseTopic do
  subject { service.call }

  before { Timecop.freeze }
  after { Timecop.return }

  let(:service) { Topics::Generate::News::ReleaseTopic.new model, user, locale }

  let(:model) { create :anime, released_on: released_on }
  let(:released_on) { Time.zone.now }

  let(:user) { BotsService.get_poster }
  let(:locale) { 'ru' }

  context 'without existing topic' do
    let(:new_release_duration) do
      Topics::Generate::News::ReleaseTopic::NEW_RELEASE_DURATION
    end

    it { expect{subject}.to change(Topic, :count).by 1 }

    context 'no release' do
      let(:released_on) { nil }

      it do
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          locale: locale,
          processed: false,
          action: AnimeHistoryAction::Released,
          value: nil
        )
        expect(subject.created_at.to_i).to eq Time.zone.now.to_i
        expect(subject.updated_at).to be_nil
      end
    end

    context 'new release' do
      let(:released_on) { new_release_duration.ago + 1.day }

      it do
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          locale: locale,
          processed: false,
          action: AnimeHistoryAction::Released,
          value: nil
        )
        expect(subject.created_at.to_i).to eq Time.zone.now.to_i
        expect(subject.updated_at).to be_nil
      end
    end

    context 'old release' do
      let(:released_on) { new_release_duration.ago - 1.day }

      it do
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          locale: locale,
          processed: true,
          action: AnimeHistoryAction::Released,
          value: nil
        )
        expect(subject.created_at.to_i).to eq model.released_on.in_time_zone.to_i
        expect(subject.updated_at).to be_nil
      end
    end
  end

  context 'with existing topic' do
    let!(:topic) do
      create :news_topic,
        linked: model,
        action: AnimeHistoryAction::Released,
        value: nil
    end

    it do
      expect{subject}.not_to change(Topic, :count)
      is_expected.to eq topic
    end
  end
end
