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
      text: 'test'
    )]
  end

  context 'unknown status' do
    let(:json) do
      "[{\"target_title\":\"Test name\",\"target_id\":999999,\"target_type\":\"Anime\",\"score\":7,\"status\":#{json_status},\"rewatches\":1,\"episodes\":30,\"text\":\"test\"}]\n"
    end
    let(:json_status) { ['null', '"zxc"'].sample }

    it do
      is_expected.to eq [ListImports::ListEntry.new(
        target_title: 'Test name',
        target_id: 999_999,
        target_type: 'Anime',
        score: 7,
        status: :unknown,
        rewatches: 1,
        episodes: 30,
        text: 'test'
      )]
    end
  end
end
