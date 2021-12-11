# frozen_string_literal: true

describe Comment::Update do
  include_context :timecop
  subject do
    described_class.call(
      comment: comment,
      params: params,
      faye: faye
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:comment) { create :comment, updated_at: 1.hour.ago }

  context 'valid params' do
    let(:params) { { body: 'text' } }

    it do
      is_expected.to eq true
      expect(comment).to be_valid
      expect(comment).to_not be_changed
      expect(comment.updated_at).to be_within(0.1).of Time.zone.now

      expect(comment.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) { { body: nil } }

    it do
      is_expected.to eq false
      expect(comment).to_not be_valid
      expect(comment).to be_changed

      expect(comment.reload).not_to have_attributes params
    end
  end
end
