# frozen_string_literal: true

describe Topics::Generate::News::EpisodeTopic do
  subject { service.call }

  let(:service) { Topics::Generate::News::EpisodeTopic.new model, user, locale, aired_at }

  let(:model) { create :anime, episodes_aired: episodes_aired }
  let(:episodes_aired) { 5 }

  let(:user) { BotsService.get_poster }
  let(:locale) { 'ru' }
  let(:aired_at) { 2.days.ago }

  context 'without existing news topic' do
    it do
      expect{subject}.to change(Topic, :count).by 1
      is_expected.to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user,
        locale: locale
      )

      expect(subject.created_at.to_i).to eq aired_at.to_i
      expect(subject.updated_at).to be_nil
    end
  end

  context 'with existing news topic' do
    let!(:topic) do
      create :news_topic,
        linked: model,
        action: AnimeHistoryAction::Episode,
        value: topic_episodes_aired
    end

    context 'for prior episode' do
      let(:topic_episodes_aired) { episodes_aired - 1 }
      it do
        is_expected.not_to eq topic
        is_expected.to be_persisted
      end
    end

    context 'for current episode' do
      let(:topic_episodes_aired) { episodes_aired }
      it { is_expected.to eq topic }
    end
  end
end
