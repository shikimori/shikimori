describe CoubTagsQuery do
  describe '#complete' do
    let!(:tag_1) { create :coub_tag, name: 'ffff' }
    let!(:tag_2) { create :coub_tag, name: 'testt' }
    let!(:tag_3) { create :coub_tag, name: 'zula zula' }
    let!(:tag_4) { create :coub_tag, name: 'test' }

    it do
      expect(CoubTagsQuery.new('test').complete).to eq [tag_2, tag_4]
      expect(CoubTagsQuery.new('z').complete).to eq [tag_3]
      expect(CoubTagsQuery.new('fofo').complete).to eq []
    end
  end
end
