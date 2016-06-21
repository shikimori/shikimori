# frozen_string_literal: true

describe Review::Update do
  subject { Review::Update.call review, params }

  let(:review) { create :review }

  let(:user) { create :user }
  let(:anime) { create :anime }

  before { subject }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        target_type: anime.class.name,
        target_id: anime.id,
        text: 'x' * Review::MINIMUM_LENGTH
      }
    end
    it do
      expect(review.errors).to be_empty
      expect(review.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        user_id: user.id,
        text: 'too short text'
      }
    end
    it do
      expect(review.errors).to have(1).item
      expect(review.reload).not_to have_attributes params
    end
  end
end
