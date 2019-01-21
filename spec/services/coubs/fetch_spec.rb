describe Coubs::Fetch do
  subject { described_class.call tags: tags, iterator: iterator }

  before do
    allow(Coubs::Request)
      .to receive(:call)
      .with('1st', 1)
      .and_return coubs_1st_1

    allow(Coubs::Request)
      .to receive(:call)
      .with('1st', 2)
      .and_return coubs_1st_2

    allow(Coubs::Request)
      .to receive(:call)
      .with('1st', 3)
      .and_return coubs_1st_3

    allow(Coubs::Request)
      .to receive(:call)
      .with('2nd', 1)
      .and_return coubs_2nd_1

    allow(Coubs::Request)
      .to receive(:call)
      .with('2nd', 2)
      .and_return coubs_2nd_2

    stub_const 'Coubs::Fetch::PER_PAGE', 2
    stub_const 'Coubs::Request::PER_PAGE', 4
  end

  let(:coubs_1st_1) { [] }
  let(:coubs_1st_2) { [] }
  let(:coubs_1st_3) { [] }

  let(:coubs_2nd_1) { [] }
  let(:coubs_2nd_2) { [] }

  def coub index, is_anime
    Coub::Entry.new(
      permalink: "coub_#{index}",
      image_template: "coub_#{index}",
      categories: is_anime ? %w[anime] : %w[gaming],
      tags: %w[],
      title: 'b',
      recoubed_permalink: nil,
      author: { permalink: 'n', name: 'm', avatar_template: 'a' },
      created_at: Time.zone.now.to_s
    )
  end

  context 'no tags' do
    let(:tags) { %w[] }
    let(:iterator) { nil }

    it do
      is_expected.to be_kind_of Coub::Results
      is_expected.to have_attributes(
        coubs: [],
        iterator: nil
      )
      expect(Coubs::Request).to_not have_received :call
    end
  end

  context 'one tag' do
    let(:tags) { %w[1st] }
    let(:coubs_1st_1) do
      [
        coub_anime_1,
        coub_not_anime_1,
        coub_anime_2,
        coub_anime_3,
        coub_anime_4,
        coub_anime_5
      ]
    end
    let(:coubs_1st_2) do
      [
        coub_not_anime_2,
        coub_anime_6,
        coub_anime_7,
        coub_anime_8
      ]
    end
    let(:coubs_1st_3) do
      [
        coub_anime_9,
        coub_anime_10,
        coub_anime_11
      ]
    end

    let(:coub_anime_1) { coub 1, true }
    let(:coub_anime_2) { coub 2, true }
    let(:coub_anime_3) { coub 3, true }
    let(:coub_anime_4) { coub 4, true }
    let(:coub_anime_5) { coub 5, true }
    let(:coub_anime_6) { coub 6, true }
    let(:coub_anime_7) { coub 7, true }
    let(:coub_anime_8) { coub 8, true }
    let(:coub_anime_9) { coub 9, true }
    let(:coub_anime_10) { coub 10, true }
    let(:coub_anime_11) { coub 11, true }
    let(:coub_not_anime_1) { coub 1, false }
    let(:coub_not_anime_2) { coub 2, false }
    let(:coub_not_anime_3) { coub 3, false }

    context 'no iterator' do
      let(:iterator) { ['1st:1:-1', nil].sample }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_1, coub_anime_2],
          iterator: '1st:1:1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context '1st:1:1' do
      let(:iterator) { '1st:1:1' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_3, coub_anime_4],
          iterator: '1st:1:3'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context '1st:1:3' do
      let(:iterator) { '1st:1:3' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_5, coub_anime_6],
          iterator: '1st:2:0'
        )
        expect(Coubs::Request).to have_received(:call).twice
      end

      context 'Coubs::Request failed and returned nil' do
        before do
          allow(Coubs::Request)
            .to receive(:call)
            .with('1st', 2)
            .and_return nil
        end

        it do
          is_expected.to be_kind_of Coub::Results
          is_expected.to have_attributes(
            coubs: [coub_anime_5],
            iterator: nil
          )
          expect(Coubs::Request).to have_received(:call).twice
        end
      end
    end

    context '1st:2:0' do
      let(:iterator) { '1st:2:0' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_7, coub_anime_8],
          iterator: '1st:3:-1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context '1st:3:-1' do
      let(:iterator) { '1st:3:-1' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_9, coub_anime_10],
          iterator: '1st:3:1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context '1st:3:1' do
      let(:iterator) { '1st:3:1' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_11],
          iterator: nil
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end
  end

  context 'multiple tags' do
    let(:tags) { %w[1st 2nd] }
    let(:iterator) { nil }

    let(:coub_anime_1) { coub 1, true }
    let(:coub_anime_2) { coub 2, true }
    let(:coub_anime_3) { coub 3, true }
    let(:coub_not_anime_1) { coub 1, false }
    let(:coub_not_anime_2) { coub 2, false }

    let(:coubs_1st_1) { [coub_anime_1] }

    context 'no more results on 2nd tag' do
      let(:coubs_2nd_1) { [coub_anime_2] }

      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_1, coub_anime_2],
          iterator: nil
        )
        expect(Coubs::Request).to have_received(:call).twice
      end
    end

    context 'has more results on 2nd tag' do
      context 'has results for 2nd tag' do
        let(:coubs_2nd_1) { [coub_anime_2, coub_anime_3] }

        it do
          is_expected.to be_kind_of Coub::Results
          is_expected.to have_attributes(
            coubs: [coub_anime_1, coub_anime_2],
            iterator: '2nd:1:0'
          )
          expect(Coubs::Request).to have_received(:call).twice
        end

        context 'next page' do
          let(:iterator) { '2nd:1:0' }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: [coub_anime_3],
              iterator: nil
            )
            expect(Coubs::Request).to have_received(:call).once
          end
        end
      end

      context 'no results on 2nd tag - fix nil next_index' do
        let(:coubs_2nd_1) { [coub_not_anime_1] }

        it do
          is_expected.to be_kind_of Coub::Results
          is_expected.to have_attributes(
            coubs: [coub_anime_1],
            iterator: nil
          )
          expect(Coubs::Request).to have_received(:call).twice
        end
      end
    end

    context 'first page 1 anime result, second page 0 results - fix infinite loop' do
      let(:iterator) { nil }
      let(:coubs_1st_1) { [coub_anime_1, coub_not_anime_1] }
      let(:coubs_1st_2) { [] }

      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_1],
          iterator: nil
        )
        expect(Coubs::Request).to have_received(:call).twice
      end
    end
  end

  describe '#parse_iterator' do
    subject do
      described_class
        .new(tags: %w[], iterator: iterator)
        .send(:parse_iterator, iterator)
    end

    context 'common' do
      let(:iterator) { 'z:0:1' }
      it { is_expected.to eq ['z', 0, 1] }
    end

    context 'with colon' do
      let(:iterator) { 'z:x:1:2' }
      it { is_expected.to eq ['z:x', 1, 2] }
    end

    context 'with more colons' do
      let(:iterator) { 'z - x: a: b:-1:5' }
      it { is_expected.to eq ['z - x: a: b', -1, 5] }
    end
  end
end
