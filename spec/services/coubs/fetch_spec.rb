describe Coubs::Fetch do
  subject { described_class.call tags: tags, iterator: iterator }

  before do
    allow(Coubs::Request)
      .to receive(:call)
      .with('zzz', 1)
      .and_return coubs_zzz_1

    allow(Coubs::Request)
      .to receive(:call)
      .with('zzz', 2)
      .and_return coubs_zzz_2

    allow(Coubs::Request)
      .to receive(:call)
      .with('zzz', 3)
      .and_return coubs_zzz_3

    allow(Coubs::Request)
      .to receive(:call)
      .with('xxx', 1)
      .and_return coubs_xxx_1

    allow(Coubs::Request)
      .to receive(:call)
      .with('xxx', 2)
      .and_return coubs_xxx_2

    stub_const 'Coubs::Fetch::PER_PAGE', 2
    stub_const 'Coubs::Request::PER_PAGE', 4
  end

  let(:coubs_zzz_1) { [] }
  let(:coubs_zzz_2) { [] }
  let(:coubs_zzz_3) { [] }

  let(:coubs_xxx_1) { [] }
  let(:coubs_xxx_2) { [] }

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
    let(:tags) { %w[zzz] }
    let(:coubs_zzz_1) do
      [
        coub_anime_1,
        coub_not_anime_1,
        coub_anime_2,
        coub_anime_3,
        coub_anime_4,
        coub_anime_5
      ]
    end
    let(:coubs_zzz_2) do
      [
        coub_not_anime_2,
        coub_anime_6,
        coub_anime_7,
        coub_anime_8
      ]
    end
    let(:coubs_zzz_3) do
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
      let(:iterator) { ['zzz:1:-1', nil].sample }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_1, coub_anime_2],
          iterator: 'zzz:1:1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context 'zzz:1:1' do
      let(:iterator) { 'zzz:1:1' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_3, coub_anime_4],
          iterator: 'zzz:1:3'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context 'zzz:1:3' do
      let(:iterator) { 'zzz:1:3' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_5, coub_anime_6],
          iterator: 'zzz:2:0'
        )
        expect(Coubs::Request).to have_received(:call).twice
      end
    end

    context 'zzz:2:0' do
      let(:iterator) { 'zzz:2:0' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_7, coub_anime_8],
          iterator: 'zzz:3:-1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context 'zzz:3:-1' do
      let(:iterator) { 'zzz:3:-1' }
      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_9, coub_anime_10],
          iterator: 'zzz:3:1'
        )
        expect(Coubs::Request).to have_received(:call).once
      end
    end

    context 'zzz:3:1' do
      let(:iterator) { 'zzz:3:1' }
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
    let(:tags) { %w[zzz xxx] }
    let(:iterator) { nil }

    let(:coub_anime_1) { coub 1, true }
    let(:coub_anime_2) { coub 2, true }
    let(:coub_anime_3) { coub 3, true }
    let(:coub_not_anime_1) { coub 1, false }
    let(:coub_not_anime_2) { coub 2, false }

    let(:coubs_zzz_1) { [coub_anime_1] }

    context 'no more results on 2nd tag' do
      let(:coubs_xxx_1) { [coub_anime_2] }

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
      let(:coubs_xxx_1) { [coub_anime_2, coub_anime_3] }

      it do
        is_expected.to be_kind_of Coub::Results
        is_expected.to have_attributes(
          coubs: [coub_anime_1, coub_anime_2],
          iterator: 'xxx:1:0'
        )
        expect(Coubs::Request).to have_received(:call).twice
      end

      context 'next page final' do
        let(:iterator) { 'xxx:1:0' }

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

    context 'first page 1 anime result, second page 0 results - fix infinite loop' do
      let(:iterator) { nil }
      let(:coubs_zzz_1) { [coub_anime_1, coub_not_anime_1] }
      let(:coubs_zzz_2) { [] }

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
end
