describe BbCodes::Tags::RepliesTag do
  subject { described_class.instance.format text }

  let(:comment_1) { create :comment }
  let(:comment_2) { create :comment }

  context 'no comments' do
    let(:text) { "\n\n[replies=12345]" }
    it { is_expected.to eq '' }
  end

  context 'one reply' do
    let(:text) { "\n\n[replies=#{comment_1.id}]" }
    it do
      is_expected.to eq(
        "<div class='b-replies translated-before single' "\
          "data-text-ru='Ответы: ' "\
          "data-text-en='Replies: ' "\
          "data-text-alt-ru='Ответ: ' "\
          "data-text-alt-en='Reply: ' "\
          ">[comment=#{comment_1.id}][/comment]</div>"
      )
    end
  end

  context 'multiple replies' do
    let(:text) { "[replies=#{comment_1.id},#{comment_2.id},999]" }
    it do
      is_expected.to eq(
        "<div class='b-replies translated-before ' "\
          "data-text-ru='Ответы: ' "\
          "data-text-en='Replies: ' "\
          "data-text-alt-ru='Ответ: ' "\
          "data-text-alt-en='Reply: ' "\
          ">[comment=#{comment_1.id}][/comment], "\
          "[comment=#{comment_2.id}][/comment]</div>"
      )
    end
  end
end
