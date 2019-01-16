describe CoubTags::Fetch do
  subject { described_class.call tags: tags, iterator: iterator }

  before do
    allow(CoubTags::CoubRequest)
      .to receive(:call)
      .with(tags[0], 1)
      .and_return coubs_1

    allow(CoubTags::CoubRequest)
      .to receive(:call)
      .with(tags[0], 2)
      .and_return coubs_2

    allow(CoubTags::CoubRequest)
      .to receive(:call)
      .with(tags[0], 3)
      .and_return coubs_3

    stub_const 'CoubTags::Fetch::PER_PAGE', 2
    stub_const 'CoubTags::CoubRequest::PER_PAGE', 2
  end

  let(:coubs_1) { [] }
  let(:coubs_2) { [] }
  let(:coubs_3) { [] }

  let(:coub_anime_1) do
    Coub::Entry.new(
      player_url: 'coub_anime_1',
      image_url: 'coub_anime_1',
      categories: %w[anime],
      tags: %w[anime]
    )
  end
  let(:coub_anime_2) do
    Coub::Entry.new(
      player_url: 'coub_anime_2',
      image_url: 'coub_anime_2',
      categories: %w[anime],
      tags: %w[anime]
    )
  end
  let(:coub_anime_3) do
    Coub::Entry.new(
      player_url: 'coub_anime_3',
      image_url: 'coub_anime_3',
      categories: %w[anime],
      tags: %w[anime]
    )
  end
  let(:coub_not_anime_1) do
    Coub::Entry.new(
      player_url: 'coub_not_anime_1',
      image_url: 'coub_not_anime_1',
      categories: %w[gaming],
      tags: %w[]
    )
  end

  let(:iterator) { nil }

  context 'last tag' do
    let(:tags) { %w[zzz] }

    context 'no iterator' do
      context 'results from 1st coub request' do
        context 'no more results' do
          let(:coubs_1) { [coub_anime_1] }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: coubs_1,
              iterator: nil
            )
            expect(CoubTags::CoubRequest).to have_received(:call).once
          end
        end

        context 'has more results' do
          let(:coubs_1) { [coub_anime_1, coub_anime_2] }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: coubs_1,
              iterator: 'zzz:2:0'
            )
            expect(CoubTags::CoubRequest).to have_received(:call).once
          end
        end
      end

      context 'results from 2nd coub request' do
        let(:coubs_1) { [coub_anime_1, coub_not_anime_1] }
        let(:coubs_2) { [coub_anime_2] }

        context 'no more results' do
          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: [coub_anime_1, coub_anime_2],
              iterator: nil
            )
            expect(CoubTags::CoubRequest).to have_received(:call).twice
          end
        end

        context 'has more results' do
          let(:coubs_1) { [coub_anime_1, coub_not_anime_1] }
          let(:coubs_2) { [coub_anime_2, coub_anime_3] }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: [coub_anime_1, coub_anime_2],
              iterator: 'zzz:2:1'
            )
            expect(CoubTags::CoubRequest).to have_received(:call).twice
          end
        end
      end
    end

    describe 'has iterator' do
      context '2nd page w/o overfetch' do
        let(:iterator) { 'zzz:2:0' }

        context 'no more results' do
          let(:coubs_2) { [coub_anime_1] }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: coubs_2,
              iterator: nil
            )
            expect(CoubTags::CoubRequest).to have_received(:call).once
          end
        end

        context 'has more results' do
          let(:coubs_2) { [coub_anime_1, coub_anime_2] }

          it do
            is_expected.to be_kind_of Coub::Results
            is_expected.to have_attributes(
              coubs: coubs_2,
              iterator: 'zzz:3:0'
            )
            expect(CoubTags::CoubRequest).to have_received(:call).once
          end
        end
      end

      context '2nd page with overfetch' do
        let(:iterator) { 'zzz:2:1' }
        let(:coubs_2) { [coub_anime_1, coub_anime_2] }
        let(:coubs_3) { [coub_not_anime_1, coub_anime_3] }

        it do
          is_expected.to be_kind_of Coub::Results
          is_expected.to have_attributes(
            coubs: [coub_anime_2, coub_anime_3],
            iterator: 'zzz:4:0'
          )
          expect(CoubTags::CoubRequest).to have_received(:call).twice
        end
      end
    end
  end
end
