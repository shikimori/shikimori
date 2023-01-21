# frozen_string_literal: true

describe Critique::Update do
  include_context :timecop, 'Wed, 16 Sep 2020 16:23:41 MSK +03:00'
  subject { described_class.call model, params, user }

  let(:model) { create :critique }
  let(:anime) { create :anime }

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
    expect(model).to_not be_changed
    expect(model.errors).to be_empty
    expect(model.changed_at).to be_within(0.1).of Time.zone.now
    expect(model.reload).to have_attributes params
  end
end
