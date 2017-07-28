describe ListImports::ParseFile do
  let(:service) { ListImports::ParseFile.new file }

  let(:list_type) { %i[mal_xml mal_xml_gz shiki_json shiki_json_gz].sample }
  let(:file) { open attributes_for(:list_import, list_type)[:list] }

  subject!(:data) { service.call }

  it do
    is_expected.to eq [{
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
end
