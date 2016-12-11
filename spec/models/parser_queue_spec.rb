describe ParserQueue do
  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :catalog_page }
  end
end
