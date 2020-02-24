describe ListImportView do
  let(:view) { ListImportView.new list_import }
  let(:list_import) do
    build :list_import, output: {
      ListImports::ImportList::ADDED => [{
        target_id: 1,
        target_title: 'z',
        target_type: 'Anime',
        status: 'completed'
      }, {
        target_id: 2,
        target_title: 'a',
        target_type: 'Anime',
        status: 'completed'
      }],
      ListImports::ImportList::UPDATED => [
        [{
          target_id: 3,
          target_title: 'z',
          target_type: 'Anime',
          status: 'completed'
        }, {
          target_id: 4,
          target_title: 'x',
          target_type: 'Anime',
          status: 'completed'
        }], [{
          target_id: 5,
          target_title: 'a',
          target_type: 'Anime',
          status: 'completed'
        }, {
          target_id: 6,
          target_title: 'b',
          target_type: 'Anime',
          status: 'completed'
        }]
      ],
      ListImports::ImportList::NOT_CHANGED => [{
        target_id: 7,
        target_title: 'z',
        target_type: 'Anime',
        status: 'completed'
      }, {
        target_id: 8,
        target_title: 'a',
        target_type: 'Anime',
        status: 'completed'
      }],
      ListImports::ImportList::NOT_IMPORTED => [{
        target_id: 9,
        target_title: 'z',
        target_type: 'Anime',
        status: 'completed'
      }, {
        target_id: 10,
        target_title: 'a',
        target_type: 'Anime',
        status: 'completed'
      }]
    }
  end

  it '#added' do
    expect(view.added).to eq [
      ListImports::ListEntry.new(list_import.output['added'][1].symbolize_keys),
      ListImports::ListEntry.new(list_import.output['added'][0].symbolize_keys)
    ]
  end

  it '#updated' do
    expect(view.updated).to eq [
      [
        ListImports::ListEntry.new(list_import.output['updated'][1][0].symbolize_keys),
        ListImports::ListEntry.new(list_import.output['updated'][1][1].symbolize_keys)
      ], [
        ListImports::ListEntry.new(list_import.output['updated'][0][0].symbolize_keys),
        ListImports::ListEntry.new(list_import.output['updated'][0][1].symbolize_keys)
      ]
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

  describe '#empty_list_error?, #error_broken_file?, #mismatched_list_type_error?' do
    context 'ERROR_EXCEPTION' do
      let(:list_import) { build_stubbed :list_import, :error_exception }
      it { expect(view).to_not be_empty_list_error }
      it { expect(view).to_not be_broken_file_error }
      it { expect(view).to_not be_mismatched_list_type_error }
    end

    context 'ERROR_EMPTY_LIST' do
      let(:list_import) { build_stubbed :list_import, :error_empty_list }
      it { expect(view).to be_empty_list_error }
      it { expect(view).to_not be_broken_file_error }
      it { expect(view).to_not be_mismatched_list_type_error }
    end

    context 'ERROR_BROKEN_FILE' do
      let(:list_import) { build_stubbed :list_import, :error_broken_file }
      it { expect(view).to_not be_empty_list_error }
      it { expect(view).to be_broken_file_error }
      it { expect(view).to_not be_mismatched_list_type_error }
    end

    context 'ERROR_MISMATCHED_LIST_TYPE' do
      let(:list_import) { build_stubbed :list_import, :error_missing_fields }
      it { expect(view).to_not be_empty_list_error }
      it { expect(view).to_not be_broken_file_error }
      it { expect(view).to be_missing_fields_error }
    end
  end
end
