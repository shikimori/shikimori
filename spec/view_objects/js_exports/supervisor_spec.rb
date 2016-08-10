describe JsExports::Supervisor do
  include_context :view_object_warden_stub

  let(:user) { build_stubbed :user }
  let(:view) { JsExports::Supervisor.instance }

  let(:user_rates_export) { JsExports::UserRatesExport.instance }
  let(:topics_export) { JsExports::TopicsExport.instance }

  describe '#export' do
    subject(:export) { view.export }
    it do
      expect(export).to be_kind_of Hash
      expect(export.keys).to eq JsExports::Supervisor::KEYS
    end
  end

  describe '#sweep' do
    before do
      allow(user_rates_export).to receive :sweep
      allow(topics_export).to receive :sweep
    end
    subject! { view.sweep html }
    let(:html) { 'test' }

    it do
      is_expected.to eq html
      expect(user_rates_export).to have_received(:sweep).with html
      expect(topics_export).to have_received(:sweep).with html
    end
  end
end
