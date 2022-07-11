describe People::Query do
  let(:query) do
    described_class.fetch(
      is_producer: is_producer,
      is_mangaka: is_mangaka,
      is_seyu: is_seyu
    )
  end
  let(:is_producer) { false }
  let(:is_mangaka) { false }
  let(:is_seyu) { false }

  include_context :timecop

  let!(:person_1) { create :person, id: 1, is_producer: true }
  let!(:person_2) { create :person, id: 2, is_mangaka: true }
  let!(:person_3) { create :person, id: 3, is_seyu: true }

  describe '.fetch' do
    subject { query }

    it { is_expected.to eq [person_1, person_2, person_3] }

    context 'producer' do
      let(:is_producer) { true }
      it { is_expected.to eq [person_1] }
    end

    context 'mangaka' do
      let(:is_mangaka) { true }
      it { is_expected.to eq [person_2] }
    end

    context 'seyu' do
      let(:is_seyu) { true }
      it { is_expected.to eq [person_3] }
    end

    describe '#search' do
      subject do
        query.search(
          phrase,
          is_mangaka: is_mangaka,
          is_producer: is_producer,
          is_seyu: is_seyu
        )
      end

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::Person).to receive(:call).with(
            phrase: phrase,
            limit: People::Query::SEARCH_LIMIT,
            is_mangaka: is_mangaka,
            is_producer: is_producer,
            is_seyu: is_seyu
          ).and_return(
            person_3.id => 987,
            person_2.id => 765
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [person_3, person_2]
          expect(Elasticsearch::Query::Person).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Person).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [person_1, person_2, person_3]
          expect(Elasticsearch::Query::Person).to_not have_received :call
        end
      end
    end
  end
end
