# frozen_string_literal: true

describe Critique::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { Critique::Update.call critique, params, user }

  let(:critique) { create :critique }
  let(:anime) { create :anime }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Critique::MIN_BODY_SIZE
      }
    end

    it do
      is_expected.to eq true
      expect(critique.errors).to be_empty
      expect(critique.changed_at).to be_within(0.1).of Time.zone.now
      expect(critique.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        text: 'too short text'
      }
    end

    it do
      is_expected.to eq false
      expect(critique.errors).to be_present
      expect(critique.reload).not_to have_attributes params
    end
  end
end
