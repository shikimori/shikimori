# frozen_string_literal: true

describe Topics::Generate::News::ReleaseTopic do
  subject { service.call }

  before { Timecop.freeze }
  after { Timecop.return }

  let(:service) { Topics::Generate::News::ReleaseTopic.new model, user, locale }
  let(:model) { create :anime }
  let(:user) { BotsService.get_poster }
  let(:locale) { 'ru' }

  context 'without existing topic' do
    it do
      expect{subject}.to change(Topic, :count).by 1
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
