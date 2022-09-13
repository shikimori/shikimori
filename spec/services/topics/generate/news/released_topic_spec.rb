# frozen_string_literal: true

describe Topics::Generate::News::ReleasedTopic do
  include_context :timecop
  subject do
    described_class.call(
      model: model,
      user: user
    )
  end

  let(:model) { create :anime }
  let(:user) { BotsService.get_poster }

  context 'without existing topic' do
    it do
      expect { subject }.to change(Topic, :count).by 1
      is_expected.to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user,
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
  end
end
