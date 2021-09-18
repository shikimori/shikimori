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
      expect(review).to be_persisted
      expect(review).to have_attributes params.merge(locale: locale.to_s)
      expect(review.errors).to be_empty

      expect(review.topics).to have(1).item
      expect(review.topics.first.locale).to eq locale.to_s
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
      expect(review).to be_new_record
      expect(review.errors).to be_present
      expect(review.topics).to be_empty
    end
  end
end
