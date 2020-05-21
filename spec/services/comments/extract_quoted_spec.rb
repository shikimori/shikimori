describe Comments::ExtractQuoted do
  subject { described_class.call text }

  describe 'no text' do
    let(:text) { nil }
    it { is_expected.to eq [] }
  end

  describe 'old style quote' do
    let(:text) { '[quote=test2]test[/quote]' }
    it do
      is_expected.to eq [{
        nickname: 'test2'
      }]
    end
  end

  describe 'just quote' do
    let(:text) { "[quote=200778;#{user.id};test2]test[/quote]" }
    it do
      is_expected.to eq [{
        comment_id: 200778,
        user_id: user.id,
        nickname: 'test2'
      }]
    end
  end

  # describe 'comment reply' do
  #   let(:comment) { create :comment, user: user }
  #   let(:text) { "[comment=#{comment.id}]test[/comment]" }
  # 
  #   it do
  #     is_expected.to eq(
  #       comment_ids: [comment.id],
  #       user_ids: [],
  #       nicknames: []
  #     )
  #   end
  # end
  # 
  # describe 'comment quote' do
  #   let(:comment) { create :comment, user: user }
  #   let(:text) { "[quote=c#{comment.id};#{user.id};test2]test[/quote]" }
  # 
  #   it do
  #     is_expected.to eq(
  #       comment_ids: [comment.id],
  #       user_ids: [user.id],
  #       nicknames: []
  #     )
  #   end
  # end
  # 
  # describe 'multiple entries' do
  #   let(:comment_1) { create :comment, user: user }
  #   let(:comment_2) { create :comment, user: user }
  #   let(:text) do
  #     <<-TEXT
  #       [comment=#{comment_1.id}]test[/comment]
  #       [comment=#{comment_1.id}]test[/comment]
  #       [comment=#{comment_2.id}]test[/comment]
  #     TEXT
  #   end
  # 
  #   it do
  #     is_expected.to eq(
  #       comment_ids: [comment_1, comment_2],
  #       user_ids: [user.id],
  #       nicknames: []
  #     )
  #   end
  # end
end
