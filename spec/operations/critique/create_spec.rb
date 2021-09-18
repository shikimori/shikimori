# frozen_string_literal: true

describe Critique::Create do
  subject(:critique) { Critique::Create.call params, locale }

  let(:anime) { create :anime }
  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Critique::MINIMUM_LENGTH,
        storyline: 1,
        characters: 2,
        animation: 3,
        music: 4,
        overall: 5
      }
    end
    it do
      expect(critique).to be_persisted
      expect(critique).to have_attributes params.merge(locale: locale.to_s)
      expect(critique.errors).to be_empty

      expect(critique.topics).to have(1).item
      expect(critique.topics.first.locale).to eq locale.to_s
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        user_id: user.id,
        text: 'x' * Critique::MINIMUM_LENGTH,
        storyline: 1,
        characters: 2,
        animation: 3,
        music: 4,
        overall: 5
      }
    end
    it do
      expect(critique).to be_new_record
      expect(critique.errors).to be_present
      expect(critique.topics).to be_empty
    end
  end
end
