# frozen_string_literal: true

describe Critique::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { Critique::Update.call review, params }

  let(:critique) { create :critique }
  let(:anime) { create :anime }

  before { subject }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Critique::MINIMUM_LENGTH
      }
    end
    it do
      expect(review.errors).to be_empty
      expect(review.changed_at).to be_within(0.1).of Time.zone.now
      expect(review.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        text: 'too short text'
      }
    end
    it do
      expect(review.errors).to be_present
      expect(review.reload).not_to have_attributes params
    end
  end
end
