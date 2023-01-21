# frozen_string_literal: true

describe Critique::Create do
  subject(:model) { described_class.call params }

  let(:anime) { create :anime, is_censored: is_censored }
  let(:is_censored) { [true, false].sample }
  let(:params) do
    {
      user_id: user.id,
      target_type: anime.class.name,
      target_id: anime.id,
      text: 'x' * Critique::MIN_BODY_SIZE,
      storyline: 1,
      characters: 2,
      animation: 3,
      music: 4,
      overall: 5
    }
  end

  it do
    expect(model).to be_persisted
    expect(model.errors).to be_empty

    expect(model.topic).to be_present
    expect(model.topic.forum_id).to eq Forum::CRITIQUES_ID
    expect(model.topic.is_censored).to eq is_censored
  end
end
