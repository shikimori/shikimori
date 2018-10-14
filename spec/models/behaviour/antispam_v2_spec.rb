describe AntispamV2 do
  describe Comment do
    let(:user) { seed :user }

    context 'by interval' do
      let!(:comment) { create :comment, created_at: created_at, user: user }
      let(:created_at) { Time.zone.now }
      let(:comment_2) { create :comment, :with_antispam, user: user }

      it do
        expect { comment_2 }.to_not change Comment, :count
      end
    end
    # it 'works' do
    #   create :comment, :with_antispam, user: user, commentable: topic

    #   expect(-> {
    #     expect(-> {
    #       create :comment, :with_antispam, user: user, commentable: topic
    #     }).to raise_error ActiveRecord::RecordNotSaved
    #   }).to_not change Comment, :count
    # end

    # it 'can be disabled' do
    #   create :comment, :with_antispam, user: user, commentable: topic

    #   expect(-> {
    #     Comment.wo_antispam do
    #       create :comment, :with_antispam, user: user, commentable: topic
    #     end
    #   }).to change(Comment, :count).by 1
    # end
  end
end
