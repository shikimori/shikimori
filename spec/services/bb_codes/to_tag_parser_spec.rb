describe BbCodes::ToTagParser do
  subject! { BbCodes::ToTagParser.call tags }
  let(:tags) { %i[image img] }

  it { is_expected.to eq [BbCodes::Tags::ImageTag, BbCodes::Tags::ImgTag] }
end
