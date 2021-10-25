class ExclusiveArcValidatable
  include ActiveModel::Validations
  vattr_initialize %i[comment_id! topic_id! review_id!]
  validates :comment_id, exclusive_arc: %i[topic_id review_id]
end

describe ExclusiveArcValidator, type: :validator do
  subject do
    ExclusiveArcValidatable.new(
      comment_id: comment_id,
      topic_id: topic_id,
      review_id: review_id
    )
  end
  let(:comment_id) { nil }
  let(:topic_id) { nil }
  let(:review_id) { nil }

  context 'nothing is set' do
    it do
      is_expected.to_not be_valid
      expect(subject.errors[:base][0]).to eq(
        'Must specify one of :comment_id, :topic_id, :review_id'
      )
    end
  end

  context 'only one field is' do
    context 'comment_id' do
      let(:comment_id) { 1 }
      it { is_expected.to be_valid }
    end

    context 'topic_id' do
      let(:topic_id) { 1 }
      it { is_expected.to be_valid }
    end

    context 'review_id' do
      let(:review_id) { 1 }
      it { is_expected.to be_valid }
    end
  end

  context 'multiple fields set' do
    let(:comment_id) { 1 }
    let(:topic_id) { 1 }

    it do
      is_expected.to_not be_valid
      expect(subject.errors[:base][0]).to eq(
        'Must specify only one of :comment_id, :topic_id, :review_id'
      )
    end
  end
end
