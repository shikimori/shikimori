describe PollVariant do
  describe 'relations' do
    it { is_expected.to belong_to :poll }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :label }
  end

  describe 'instance methods' do
    describe '#votes_percent' do
      let(:poll) { create :poll }

      context 'has votes' do
        let! :poll_variant_1 do
          create :poll_variant, cached_votes_total: 5, poll: poll
        end
        let! :poll_variant_2 do
          create :poll_variant, cached_votes_total: 10, poll: poll
        end

        it { expect(poll_variant_1.votes_percent).to eq 33.33 }
        it { expect(poll_variant_2.votes_percent).to eq 66.67 }
      end

      context 'no votes' do
        let! :poll_variant do
          create :poll_variant, cached_votes_total: 0, poll: poll
        end
        it { expect(poll_variant.votes_percent).to eq 0 }
      end
    end
  end
end
