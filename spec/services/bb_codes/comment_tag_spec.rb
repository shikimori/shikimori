describe BbCodes::CommentTag do
  let(:tag) { BbCodes::CommentTag.instance }

  describe '#format' do
    subject { tag.format text }
    let(:text) { "[comment=#{comment.id}]morr[/comment], test" }

    context 'valid comment_id' do
      let(:comment) { create :comment }
      it do
        is_expected.to eq BbCodes::UrlTag.instance.format(
          "[url=#{UrlGenerator.instance.comment_url comment}]morr[/url], test"
        )
      end
    end

    context 'invalid comment_id' do
      let(:comment) { build_stubbed :comment }
      it { is_expected.to eq 'morr, test' }
    end
  end
end
