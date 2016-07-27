describe Comments::ExtractQuotes do
  let(:service) { Comments::ExtractQuotes.new text }

  describe '#extract' do
    let(:user) { create :user }

    subject { service.call }

    describe 'just quote' do
      let(:topic) { create :topic, user: user }
      let(:text) { "[quote=200778;#{user.id};test2]test[/quote]" }
      it { is_expected.to eq [[nil, user]] }
    end

    describe 'comment reply' do
      let(:comment) { create :comment, user: user }
      let(:text) { "[comment=#{comment.id}]test[/comment]" }

      it { is_expected.to eq [[comment, user]] }
    end

    describe 'comment quote' do
      let(:comment) { create :comment, user: user }
      let(:text) { "[quote=c#{comment.id};#{user.id};test2]test[/quote]" }

      it { is_expected.to eq [[comment, user]] }
    end
  end
end
