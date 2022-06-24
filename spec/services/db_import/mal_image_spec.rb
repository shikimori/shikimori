describe DbImport::MalImage do
  let(:service) do
    described_class.new(
      entry: entry,
      image_url: image_url
    )
  end
  let(:entry) { build :anime }
  let(:image_url) { 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/240px-PNG_transparency_demonstration_1.png' }

  before do
    allow(DbImport::ImagePolicy)
      .to receive(:new)
      .with(entry, image_url)
      .and_return(image_policy)

    if is_nil_import
      allow(service).to receive(:download_image).and_return nil
    end
  end
  let(:image_policy) { double need_import?: need_import }
  let(:is_nil_import) { false }
  subject! { service.call }

  context 'need import', :vcr do
    let(:need_import) { true }
    it { expect(entry.image).to be_present }

    context 'does not delete image' do
      let(:entry) { create :anime, :with_image }
      let(:image_url) { nil }
      it { expect(entry.image).to be_present }
    end

    context 'broken import rollbacks to previous image' do
      let(:is_nil_import) { true }
      let(:entry) { create :anime, :with_image }

      it { expect(entry.image).to be_present }
    end
  end

  context 'dont need import' do
    let(:need_import) { false }
    it { expect(entry.image).to_not be_present }
  end
end
