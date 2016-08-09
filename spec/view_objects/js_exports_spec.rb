describe JsExports do
  include_context :view_object_warden_stub

  let(:user) { build_stubbed :user }
  let(:view) { JsExports.instance }

  let(:user_rates_tracker) { UserRates::Tracker.instance }

  describe '#export' do
    subject(:export) { view.export }
    it do
      expect(export).to be_kind_of Hash
      expect(export.keys).to eq JsExports::KEYS
    end
  end

  describe '#sweep' do
    before { allow(user_rates_tracker).to receive :sweep }
    subject! { view.sweep html }
    let(:html) { 'test' }

    it do
      is_expected.to eq html
      expect(user_rates_tracker).to have_received(:sweep).with html
    end
  end
end
