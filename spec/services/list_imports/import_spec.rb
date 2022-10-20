describe ListImports::Import do
  let(:service) { ListImports::Import.new list_import }
  let!(:anime) { nil }

  before { allow(Achievements::Track).to receive :perform_async }

  subject! { service.call }

  context 'valid list' do
    let(:list_type) { %i[mal_xml mal_xml_gz shiki_json shiki_json_gz].sample }
    let(:list_import) { create :list_import, list_type, :anime, :pending, user: user }
    let!(:anime) { create :anime, id: 999_999, name: 'Test name' }

    it do
      expect(list_import).to be_finished
      expect(list_import.output).to eq(
        ListImports::ImportList::ADDED => JSON.parse([
          ListImports::ListEntry.build(user.anime_rates.first)
        ].to_json),
        ListImports::ImportList::UPDATED => [],
        ListImports::ImportList::NOT_IMPORTED => [],
        ListImports::ImportList::NOT_CHANGED => []
      )
      expect(list_import).to_not be_changed

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

      expect(user.history).to have(1).item
      expect(user.history.first).to have_attributes(
        action: UserHistoryAction::ANIME_IMPORT,
        value: '1'
      )

      expect(Achievements::Track)
        .to have_received(:perform_async)
        .with list_import.user_id, nil, Types::Neko::Action[:reset]
    end
  end

  context 'empty list' do
    let(:list_import) do
      create :list_import, :shiki_json_empty, :manga, :pending, user: user
    end

    it do
      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => { 'type' => ListImport::ERROR_EMPTY_LIST }
      )

      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(user.history).to be_empty

      expect(Achievements::Track).to_not have_received :perform_async
    end
  end

  context 'wrong list type' do
    let(:list_import) do
      create :list_import, :shiki_json, :manga, :pending, user: user
    end

    it do
      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => { 'type' => ListImport::ERROR_MISMATCHED_LIST_TYPE }
      )

      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(user.history).to be_empty

      expect(Achievements::Track).to_not have_received :perform_async
    end
  end

  context 'broken file' do
    let(:list_import) do
      create :list_import, :broken_file, :anime, :pending, user: user
    end

    it do
      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => { 'type' => ListImport::ERROR_BROKEN_FILE }
      )

      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(user.history).to be_empty

      expect(Achievements::Track).to_not have_received :perform_async
    end
  end

  context 'broken list' do
    let(:list_import) do
      create :list_import, :shiki_json_broken, :anime, :pending, user: user
    end

    it do
      expect(list_import).to be_failed
      expect(list_import.output).to have(1).item
      expect(list_import.output['error']).to have(4).items
      expect(list_import.output['error']['type'])
        .to eq ListImport::ERROR_EXCEPTION
      expect(list_import.output['error']['class']).to eq 'JSON::ParserError'
      expect(list_import.output['error']['message'])
        .to match(/\d+: unexpected token at ''/)
      expect(list_import.output['error']['backtrace'])
        .to have_at_least(80).items

      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(user.history).to be_empty

      expect(Achievements::Track).to_not have_received :perform_async
    end
  end

  context 'missing field' do
    let(:list_import) do
      create :list_import, :shiki_json_broken_2, :anime, :pending, user: user
    end

    it do
      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => {
          'type' => ListImport::ERROR_MISSING_FIELDS,
          'fields' => %w[target_type status]
        }
      )

      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(user.history).to be_empty

      expect(Achievements::Track).to_not have_received :perform_async
    end
  end
end
