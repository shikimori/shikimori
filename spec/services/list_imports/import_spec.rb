describe ListImports::Import do
  let(:service) { ListImports::Import.new list_import }
  let(:user) { seed :user }

  subject! { service.call }

  context 'valid list' do
    let(:list_type) { %i[mal_xml mal_xml_gz shiki_json shiki_json_gz].sample }
    let(:list_import) { create :list_import, list_type, :anime, :pending, user: user }

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

      expect(list_import).to be_finished
      expect(list_import.output).to eq(
        ListImports::ImportList::ADDED => [],
        ListImports::ImportList::UPDATED => [],
        ListImports::ImportList::NOT_IMPORTED => []
      )
      expect(list_import).to_not be_changed
    end
  end

  context 'empty list' do
    let(:list_import) do
      create :list_import, :shiki_json_empty, :manga, :pending, user: user
    end

    it do
      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => { 'type' => ListImport::ERROR_EMPTY_LIST }
      )
    end
  end

  context 'wrong list type' do
    let(:list_import) do
      create :list_import, :shiki_json, :manga, :pending, user: user
    end

    it do
      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(list_import).to be_failed
      expect(list_import.output).to eq(
        'error' => { 'type' => ListImport::ERROR_MISMATCHED_LIST_TYPE }
      )
    end
  end

  context 'broken list' do
    let(:list_import) do
      create :list_import, :shiki_json_broken, :anime, :pending, user: user
    end

    it do
      expect(user.anime_rates).to be_empty
      expect(user.manga_rates).to be_empty

      expect(list_import).to be_failed
      expect(list_import.output).to have(1).item
      expect(list_import.output['error']).to have(4).items
      expect(list_import.output['error']['type'])
        .to eq ListImport::ERROR_EXCEPTION
      expect(list_import.output['error']['class']).to eq 'JSON::ParserError'
      expect(list_import.output['error']['message'])
        .to eq "416: unexpected token at ''"
      expect(list_import.output['error']['backtrace']).to have(79).items
    end
  end
end
