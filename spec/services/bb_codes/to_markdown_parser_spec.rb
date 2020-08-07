describe BbCodes::ToMarkdownParser do
  subject! { BbCodes::ToMarkdownParser.call tags }
  let(:tags) { %i[headline] }

  it { is_expected.to eq [BbCodes::Markdown::HeadlineParser] }
end
