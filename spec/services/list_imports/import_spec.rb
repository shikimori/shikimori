describe ListImports::Import do
  let(:service) { ListImports::Import.new list_import }
  let(:list_type) { %i[mal_xml mal_xml_gz shiki_json shiki_json_gz].sample }
  let(:list_import) { create :list_import, list_type, :pending, user: user }
  let(:user) { seed :user }

  subject! { service.call }

  it do
    expect(list_import).to be_finished
    expect(user.user_rates).to have(1).item
    expect(user.user_rates.first).to have_attributes(
      target_id: 999,
      target_type: 'Anime',
      score: 7,
      status: 'completed',
      rewatches: 1,
      episodes: 30,
      text: 'test',
      volumes: 0,
      chapters: 0
    )
  end
end
