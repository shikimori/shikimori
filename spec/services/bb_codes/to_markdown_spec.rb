describe BbCodes::ToMarkdown do
  subject! { BbCodes::ToMarkdown.call tags }
  let(:tags) { %i[headline] }

  it { is_expected.to eq [BbCodes::Markdown::HeadlineParser] }
end
