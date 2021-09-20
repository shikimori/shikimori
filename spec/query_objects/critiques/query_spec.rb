describe Critiques::Query do
  let(:db_entry) { create :anime }

  before do
    Critique.wo_antispam do
      @critiques = [
        create(:critique, target: db_entry, user: user),
        create(:critique, target: db_entry, user: user, created_at: Critiques::Query::NEW_REVIEW_BUBBLE_INTERVAL.ago),
        create(:critique, target: db_entry, user: user),
        create(:critique, target: db_entry, user: user, locale: :en)
      ]
    end
  end

  describe '#call' do
    subject { described_class.call db_entry, locale: locale, id: id }
    let(:locale) { :ru }

    describe 'with_id' do
      let(:id) { @critiques[0].id }
      it { is_expected.to eq [@critiques[0]] }
    end

    describe 'without_id' do
      let(:id) { [0, nil].sample }
      it { is_expected.to eq [@critiques[2], @critiques[0], @critiques[1]] }
    end
  end
end
