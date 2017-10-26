describe BbCodes::ToTag do
  subject! { BbCodes::ToTag.call tags }
  let(:tags) { %i[image img] }

  it { is_expected.to eq [BbCodes::Tags::ImageTag, BbCodes::Tags::ImgTag] }
end
