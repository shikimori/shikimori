# frozen_string_literal: true

describe Topics::Generate::News::AnonsTopic do
  include_context :timecop
  subject do
    described_class.call(
      model: model,
      user: user,
      locale: locale
    )
  end

  let(:model) { create :anime }
  let(:user) { BotsService.get_poster }
  let(:locale) { 'en' }

  context 'without existing topic' do
    it do
      expect { subject }.to change(Topic, :count).by 1
      is_expected.to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user,
        locale: locale,
        processed: false,
        action: AnimeHistoryAction::Anons,
        value: nil
      )
      expect(subject.created_at.to_i).to eq Time.zone.now.to_i
      expect(subject.updated_at).to be_nil
    end
  end

  context 'with existing topic' do
    let!(:topic) do
      create :news_topic,
        linked: model,
        action: AnimeHistoryAction::Anons,
        value: nil,
        locale: topic_locale
    end

    context 'for the same locale' do
      let(:topic_locale) { locale }
      it do
        expect { subject }.not_to change(Topic, :count)
        is_expected.to eq topic
      end
    end

    context 'for different locale' do
      let(:topic_locale) { 'ru' }
      it 'generates topic for new locale' do
        expect { subject }.to change(Topic, :count).by 1
        is_expected.not_to eq topic
      end
    end
  end
end
