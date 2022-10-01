# frozen_string_literal: true

describe Topics::Generate::News::ContestStatusTopic do
  include_context :timecop
  subject do
    described_class.call(
      model: model,
      user: user,
      action: action
    )
  end

  let(:model) { create :contest }
  let(:action) { Types::Topic::ContestStatusTopic::Action[:finished] }
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
        action: action.to_s,
        value: nil
      )
      expect(subject.created_at).to be_within(0.1).of(Time.zone.now)
      expect(subject.updated_at).to be_within(0.1).of(Time.zone.now)
    end
  end

  context 'with existing topic' do
    let!(:topic) do
      create :contest_status_topic,
        linked: model,
        action: action,
        value: nil
    end
  end
end
