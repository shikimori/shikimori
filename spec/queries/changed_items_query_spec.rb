describe ChangedItemsQuery do
  let(:query) { ChangedItemsQuery.new Anime }
  let!(:user_change_1) { create :user_change, item_id: 1, model: Manga.name, column: 'description', status: UserChangeStatus::Taken }
  let!(:user_change_2) { create :user_change, item_id: 2, model: Anime.name, column: 'description', status: UserChangeStatus::Taken }
  let!(:user_change_3) { create :user_change, item_id: 3, model: Character.name, column: 'description', status: UserChangeStatus::Taken }
  let!(:user_change_4) { create :user_change, item_id: 4, model: Anime.name, column: 'description', status: UserChangeStatus::Accepted }
  let!(:user_change_5) { create :user_change, item_id: 5, model: Anime.name, column: 'description', status: UserChangeStatus::Rejected }
  let!(:user_change_6) { create :user_change, item_id: 4, model: Anime.name, column: 'russian', status: UserChangeStatus::Accepted }

  it { expect(query.fetch_ids).to eq [2, 4] }
end
