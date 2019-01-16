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

    stub_const 'CoubTags::Fetch::PER_PAGE', 2
    stub_const 'CoubTags::CoubRequest::PER_PAGE', 2
  end

  let(:coubs_1) { [] }
  let(:coubs_2) { [] }

  let(:coub_anime_1) do
    Coub::Entry.new(
      player_url: 'zxc_1',
      image_url: 'qwe_1',
      categories: %w[anime],
      tags: %w[anime]
    )
  end
  let(:coub_anime_2) do
    Coub::Entry.new(
      player_url: 'zxc_2',
      image_url: 'qwe_2',
      categories: %w[anime],
      tags: %w[anime]
    )
  end
  let(:coub_not_anime_1) do
    Coub::Entry.new(
      player_url: 'zxc_3',
      image_url: 'qwe_3',
      categories: %w[gaming],
      tags: %w[]
    )
  end

  let(:iterator) { nil }

  context 'last tag' do
    let(:tags) { %w[zzz] }

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
            iterator: 'zzz:2'
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
    end
  end
end
