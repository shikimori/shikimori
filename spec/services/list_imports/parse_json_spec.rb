describe ListImports::ParseJson do
  let(:parser) { ListImports::ParseJson.new json }
  subject! { parser.call }

  let(:file) { attributes_for(:list_import, :shiki_json)[:list] }
  let(:json) { open(file).read }

  it do
    is_expected.to eq [ListImports::ListEntry.new(
      target_title: 'Test name',
      target_id: 999_999,
      target_type: 'Anime',
      score: 7,
      status: 'completed',
      rewatches: 1,
      episodes: 30,
      text: 'test',
      volumes: 0,
      chapters: 0
    )]
  end
end
