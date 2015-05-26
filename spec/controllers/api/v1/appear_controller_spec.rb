describe Api::V1::AppearController do
  let!(:topic) { create :entry }
  let(:user2) { create :user }
  let(:user3) { create :user }
  let!(:comment) { create :comment, commentable_id: topic.id, commentable_type: topic.class.name, user_id: user2.id }
  let!(:comment2) { create :comment, commentable_id: topic.id, commentable_type: topic.class.name }

  describe 'read' do
    let(:user) { create :user }

    it 'authorized' do
      expect {
        post :read, ids: "comment-#{comment.id}"
      }.to change(CommentView, :count).by 0

      expect(response).to be_redirect
    end

    describe 'user signed in' do
      let(:comment2) { create :comment }
      before { sign_in user }

      it 'success' do
        expect(response).to be_success
      end

      it 'one view' do
        expect {
          post :read, ids: "comment-#{comment.id}"
        }.to change(CommentView, :count).by 1

      end

      it 'multiple views', :show_in_doc do
        expect {
          expect {
            post :read, ids: "comment-#{comment.id},comment-#{comment2.id},entry-#{topic.id}"
          }.to change(CommentView, :count).by 2
        }.to change(EntryView, :count).by 1
      end

      it 'only once' do
        expect {
          post :read, ids: "comment-#{comment.id}"
          post :read, ids: "comment-#{comment.id}"
        }.to change(CommentView, :count).by 1
      end

      it 'no views for unexisted' do
        expect {
          post :read, ids: "comment-999999"
        }.to change(CommentView, :count).by 0
      end


      it '"reads" comment notification message' do
        original_comment = create :comment, commentable: topic, user: user
        reply_comment = nil

        # создаём ответ на комментарий
        expect {
          reply_comment = create(:comment, :with_notify_quotes, commentable: topic, user: user3, body: "[comment=#{original_comment.id}]ня[/comment]")
        }.to change(Message, :count).by 1

        # должно создаться уведомление о новом комменте
        message = Message.last
        expect(message.read).to be_falsy
        expect(message.from_id).to eq user3.id
        expect(message.to_id).to eq user.id
        expect(message.kind).to eq MessageType::QuotedByUser

        post :read, ids: "comment-#{reply_comment.id}", log: true

        # то самое уведомление должно стать прочитанным
        message = Message.find(message.id)
        expect(message.read).to be_truthy
      end
    end
  end
end
