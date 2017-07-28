describe ListImports::ImportList do
  let(:service) { ListImports::ImportList.new list_import, list }

  let(:list_import) { create :list_import, :anime, user: user }
  let(:user) { seed :user }
  let(:list) do
    [{
      target_title: 'Test name',
      target_id: 999_999,
      target_type: 'Anime',
      score: 7,
      status: 'completed',
      rewatches: 1,
      episodes: 30,
      text: 'test'
    }]
  end
  let!(:target) { create :anime, id: list.first[:target_id] }

  subject! { service.call }

  context 'new entry' do
    it do
      expect(user.anime_rates).to have(1).item
      expect(user.anime_rates.first).to have_attributes(
        target_id: 999_999,
        target_type: 'Anime',
        score: 7,
        status: 'completed',
        rewatches: 1,
        episodes: 30,
        text: 'test',
        volumes: 0,
        chapters: 0
      )
      expect(user.manga_rates).to be_empty

      expect(list_import.output).to eq(
        ListImports::ImportList::ADDED => [list[0]],
        ListImports::ImportList::UPDATED => [],
        ListImports::ImportList::NOT_IMPORTED => []
      )
      expect(list_import).to_not be_changed
    end
  end

  context 'existing entry' do
    context 'replace duplicate_policy' do
    end

    context 'ignore duplicate_policy' do
    end
  end

  context 'not existing entry' do
    let(:target) { nil }
  end
end
