describe ListImportView do
  let(:view) { ListImportView.new list_import }
  let(:list_import) do
    build :list_import, output: {
      ListImports::ImportList::ADDED => [{
        target_id: 1,
        target_title: 'z',
        target_type: 'Anime'
      }, {
        target_id: 2,
        target_title: 'a',
        target_type: 'Anime'
      }],
      ListImports::ImportList::NOT_CHANGED => [{
        target_id: 3,
        target_title: 'z',
        target_type: 'Anime'
      }, {
        target_id: 4,
        target_title: 'a',
        target_type: 'Anime'
      }],
      ListImports::ImportList::NOT_IMPORTED => [{
        target_id: 5,
        target_title: 'z',
        target_type: 'Anime'
      }, {
        target_id: 6,
        target_title: 'a',
        target_type: 'Anime'
      }]
    }
  end

  it '#added' do
    expect(view.added).to eq [
      ListImports::ListEntry.new(list_import.output['added'][1].symbolize_keys),
      ListImports::ListEntry.new(list_import.output['added'][0].symbolize_keys)
    ]
  end

  it '#not_changed' do
    expect(view.not_changed).to eq [
      ListImports::ListEntry.new(list_import.output['not_changed'][1].symbolize_keys),
      ListImports::ListEntry.new(list_import.output['not_changed'][0].symbolize_keys)
    ]
  end

  it '#not_imported' do
    expect(view.not_imported).to eq [
      ListImports::ListEntry.new(list_import.output['not_imported'][1].symbolize_keys),
      ListImports::ListEntry.new(list_import.output['not_imported'][0].symbolize_keys)
    ]
  end
end
