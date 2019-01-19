describe Tags::ImportCoubTags do
  subject { described_class.call tags }
  let(:tags) { %w[naruto anime] }
  let(:current_tags) { CoubTag.pluck(:name).sort }

  context 'all new tags' do
    let!(:coub_tag) { create :coub_tag, name: 'zxc' }
    it do
      expect { subject }.to change(CoubTag, :count).by 2
      expect(current_tags).to eq %w[anime naruto zxc]
    end
  end

  context 'present tags' do
    let!(:coub_tag) { create :coub_tag, name: 'anime' }
    it do
      expect { subject }.to change(CoubTag, :count).by 1
      expect(current_tags).to eq %w[anime naruto]
    end
  end
end
