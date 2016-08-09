describe JsExports do
  include_context :view_object_warden_stub

  let(:user) { build_stubbed :user }
  let(:view) { JsExports.instance }

  describe '#export' do
    subject(:export) { view.export }
    it do
      expect(export).to be_kind_of Hash
      expect(export.keys).to eq JsExports::KEYS
    end
  end
end
