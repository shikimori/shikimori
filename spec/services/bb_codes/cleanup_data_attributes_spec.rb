describe BbCodes::CleanupDataAttributes do
  subject { described_class.call value }

  let(:value) do
    'data-zxc=fofo data-action=asd data-action data-remote data-test'
  end

  it { is_expected.to eq 'data-zxc=fofo data-test' }
end
