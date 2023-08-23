describe ChangedItemsQuery do
  let(:query) { described_class.new Anime }

  around(:each) do |example|
    Version.wo_antispam { example.run }
  end

  let(:item_1) { create :manga, id: 1 }
  let(:item_2) { create :anime, id: 2 }
  let(:item_3) { create :character, id: 3 }
  let(:item_4) { create :anime, id: 4 }
  let(:item_5) { create :anime, id: 5 }
  let!(:version_1) do
    create :version, :taken,
      item: item_1,
      item_diff: { 'description_ru' => ['1', '2'] }
  end
  let!(:version_2) do
    create :version, :taken,
      item: item_2,
      item_diff: { 'description_ru' => ['1', '2'] }
  end
  let!(:version_3) do
    create :version, :taken,
      item: item_3,
      item_diff: { 'description_ru' => ['1', '2'] }
  end
  let!(:version_4) do
    create :version, :accepted,
      item: item_4,
      item_diff: { 'description_ru' => ['1', '2'] }
  end
  let!(:version_5) do
    create :version, :rejected,
      item: item_5,
      item_diff: { 'description_ru' => ['1', '2'] }
  end
  let!(:version_6) do
    create :version, :accepted,
      item: item_4,
      item_diff: { 'russian' => ['1', '2'] }
  end

  it { expect(query.fetch_ids).to eq [2, 4] }
end
