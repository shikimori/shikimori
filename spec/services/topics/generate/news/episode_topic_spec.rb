# frozen_string_literal: true

describe Topics::Generate::News::EpisodeTopic do
  subject do
    described_class.call(
      model: model,
      user: user,
      locale: locale,
      aired_at: aired_at,
      episode: episode
    )
  end

  let(:model) { create :anime }
  let(:episode) { 5 }

  let(:user) { BotsService.get_poster }
  let(:locale) { 'en' }
  let(:aired_at) { 2.days.ago }

  context 'without existing news topic' do
    it do
      expect { subject }.to change(Topic, :count).by 1
      is_expected.to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user,
        locale: locale,
        processed: false,
        action: AnimeHistoryAction::Episode,
        value: episode.to_s
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
        value: topic_episodes_aired,
        locale: topic_locale
    end

    context 'for the same locale' do
      let(:topic_locale) { locale }

      context 'for prior episode' do
        let(:topic_episodes_aired) { episode - 1 }
        it 'generates topic' do
          is_expected.not_to eq topic
          is_expected.to be_persisted
        end
      end

      context 'for current episode' do
        let(:topic_episodes_aired) { episode }
        it 'does not generate topic' do
          expect { subject }.not_to change(Topic, :count)
          is_expected.to eq topic
        end
      end
    end

    context 'for different locale and current episode' do
      let(:topic_episodes_aired) { episode }
      let(:topic_locale) { 'ru' }

      it 'generates topic for new locale' do
        expect { subject }.to change(Topic, :count).by 1
        is_expected.not_to eq topic
      end
    end
  end
end
