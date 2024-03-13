describe ListImports::ParseXml do
  let(:parser) { ListImports::ParseXml.new xml }
  subject! { parser.call }

  context 'anime' do
    let(:file) { attributes_for(:list_import, :mal_xml)[:list] }
    let(:xml) { open(file).read }

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
  end

  context 'manga' do
    let(:id_field) { %w[manga_mangadb_id series_mangadb_id].sample }
    let(:status_field) { %w[my_status shiki_status].sample }
    let(:xml) do
      <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <myanimelist>
          <myinfo>
            <user_export_type>#{ListImports::ParseXml::MANGA_TYPE}</user_export_type>
          </myinfo>
          <manga>
            <series_title>Test name</series_title>
            <#{id_field}>1</#{id_field}>
            <my_read_volumes>2</my_read_volumes>
            <my_read_chapters>3</my_read_chapters>
            <my_times_watched>4</my_times_watched>
            <my_score>5</my_score>
            <#{status_field}>Plan to Read</#{status_field}>
            <my_comments><![CDATA[test test]]></my_comments>
          </manga>
        </myanimelist>
      XML
    end

    it do
      is_expected.to eq [ListImports::ListEntry.new(
        target_title: 'Test name',
        target_id: 1,
        target_type: 'Manga',
        status: 'planned',
        volumes: 2,
        chapters: 3,
        rewatches: 4,
        score: 5.0,
        text: 'test test'
      )]
    end
  end
end
