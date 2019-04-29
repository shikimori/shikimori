describe ListImports::ImportList do
  let(:service) { ListImports::ImportList.new list_import, list }

  let(:list_import) { create :list_import, :anime, duplicate_policy, user: user }
  let(:duplicate_policy) { Types::ListImport::DuplicatePolicy[:replace] }
  let(:list) do
    [ListImports::ListEntry.new(
      target_title: 'Test name',
      target_id: 999_999,
      target_type: 'Anime',
      score: 7,
      status: 'completed',
      rewatches: 1,
      episodes: 30,
      text: 'test'
    )]
  end
  let!(:target) do
    create :anime,
      id: list.first.target_id,
      name: list.first.target_title
  end
  let!(:user_rate) { nil }

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
        ListImports::ImportList::ADDED => JSON.parse([list[0]].to_json),
        ListImports::ImportList::UPDATED => [],
        ListImports::ImportList::NOT_IMPORTED => [],
        ListImports::ImportList::NOT_CHANGED => []
      )
      expect(list_import).to_not be_changed
    end
  end

  context 'existing entry' do
    let!(:user_rate) do
      create :user_rate,
        user: user,
        target: target,
        status: 'planned',
        episodes: 0,
        rewatches: 0,
        score: 0
    end
    let!(:user_rate_list_entry) { ListImports::ListEntry.build user_rate }

    context 'replace duplicate_policy' do
      let(:duplicate_policy) { Types::ListImport::DuplicatePolicy[:replace] }

      it do
        expect(user.anime_rates).to have(1).item
        expect(user.anime_rates.first).to eq user_rate.reload
        expect(user_rate).to have_attributes(
          status: list[0].status.to_s,
          episodes: list[0].episodes,
          rewatches: list[0].rewatches,
          score: list[0].score
        )
        expect(user.manga_rates).to be_empty

        expect(list_import.output).to eq(
          ListImports::ImportList::ADDED => [],
          ListImports::ImportList::UPDATED => JSON.parse(
            [[user_rate_list_entry, list[0]]].to_json
          ),
          ListImports::ImportList::NOT_IMPORTED => [],
          ListImports::ImportList::NOT_CHANGED => []
        )
        expect(list_import).to_not be_changed
      end
    end

    context 'ignore duplicate_policy' do
      let(:duplicate_policy) { Types::ListImport::DuplicatePolicy[:ignore] }

      it do
        expect(user.anime_rates).to have(1).item
        expect(user.anime_rates.first).to eq user_rate.reload
        expect(user_rate).to have_attributes(
          status: 'planned',
          episodes: 0,
          rewatches: 0,
          score: 0
        )
        expect(user.manga_rates).to be_empty

        expect(list_import.output).to eq(
          ListImports::ImportList::ADDED => [],
          ListImports::ImportList::UPDATED => [],
          ListImports::ImportList::NOT_IMPORTED => JSON.parse([list[0]].to_json),
          ListImports::ImportList::NOT_CHANGED => []
        )
        expect(list_import).to_not be_changed
      end
    end

    context 'not changed entry' do
      let(:duplicate_policy) { Types::ListImport::DuplicatePolicy[:replace] }
      let!(:user_rate) do
        create :user_rate,
          user: user,
          target: target,
          status: list[0].status,
          episodes: list[0].episodes,
          rewatches: list[0].rewatches,
          score: list[0].score,
          text: list[0].text
      end

      it do
        expect(user.anime_rates).to have(1).item
        expect(user.anime_rates.first).to eq user_rate
        expect(user.manga_rates).to be_empty

        expect(list_import.output).to eq(
          ListImports::ImportList::ADDED => [],
          ListImports::ImportList::UPDATED => [],
          ListImports::ImportList::NOT_IMPORTED => [],
          ListImports::ImportList::NOT_CHANGED => JSON.parse([list[0]].to_json)
        )
        expect(list_import).to_not be_changed
      end
    end
  end

  context 'not existing entry' do
    let(:target) { nil }

    it do
      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(list_import.output).to eq(
        ListImports::ImportList::ADDED => [],
        ListImports::ImportList::UPDATED => [],
        ListImports::ImportList::NOT_IMPORTED => JSON.parse([list[0]].to_json),
        ListImports::ImportList::NOT_CHANGED => []
      )
      expect(list_import).to_not be_changed
    end
  end
end
