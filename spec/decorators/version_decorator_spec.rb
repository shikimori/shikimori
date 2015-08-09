describe VersionDecorator do
  let(:decorator) { version.decorate }
  let(:version) { build_stubbed :version, item_diff: { name: [1,2], russian: [3,4] } }

  describe '#changed_fields' do
    it { expect(decorator.changed_fields).to eq ['name', 'russian'] }
  end
end
