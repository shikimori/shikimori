describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :text }
  end

  describe 'instance methods' do
    describe '#votes_percent' do
      let(:poll) { create :poll }
      let!(:poll_variant_1) { create :poll_variant, cached_votes_total: 5, poll: poll }
      let!(:poll_variant_2) { create :poll_variant, cached_votes_total: 10, poll: poll }

      it { expect(poll_variant_1.votes_percent).to eq 33.33 }
      it { expect(poll_variant_2.votes_percent).to eq 66.67 }
    end
  end
end
