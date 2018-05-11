describe Animes::GenerateBannedRelations, :vcr do
  let(:service) { described_class.new additional_data }
  subject { service.call }

  let(:additional_data) { [%w[A1 A2], [%w[A1 A2]]].sample }

  before do
    stub_const 'Animes::BannedRelations::CONFIG_PATH', shiki_config_path

    allow(service).to receive :clear_rails_cache
    allow(service).to receive :touch_restart

    allow(Anime).to receive(:find).and_return double name: 'zxc'
    allow(Manga).to receive(:find).and_return double name: 'zxc'

    File.open(shiki_config_path, 'w') do |f|
      f.write(
        <<~YML
          -
            - A10033 # Toriko
            - A21 # One Piece
            - A813 # Dragon Ball Z
        YML
      )
    end
  end
  let(:shiki_config_path) { '/tmp/test_banned_relations.yml' }

  it { expect(subject).to have(34).items }
end
