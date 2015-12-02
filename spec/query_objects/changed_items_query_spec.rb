describe ChangedItemsQuery do
  let(:query) { ChangedItemsQuery.new Anime }
  let(:item_1) { create :manga, id: 1 }
  let(:item_2) { create :anime, id: 2 }
  let(:item_3) { create :character, id: 3 }
  let(:item_4) { create :anime, id: 4 }
  let(:item_5) { create :anime, id: 5 }
  let!(:version_1) { create :version, item: item_1,
    item_diff: { 'description_ru' => ['1','2'] }, state: :taken }
  let!(:version_2) { create :version, item: item_2,
    item_diff: { 'description_ru' => ['1','2'] }, state: :taken }
  let!(:version_3) { create :version, item: item_3,
    item_diff: { 'description_ru' => ['1','2'] }, state: :taken }
  let!(:version_4) { create :version, item: item_4,
    item_diff: { 'description_ru' => ['1','2'] }, state: :accepted }
  let!(:version_5) { create :version, item: item_5,
    item_diff: { 'description_ru' => ['1','2'] }, state: :rejected }
  let!(:version_6) { create :version, item: item_4,
    item_diff: { 'russian' => ['1','2'] }, state: :accepted }

  it { expect(query.fetch_ids).to eq [2, 4] }
end
