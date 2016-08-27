describe Api::V1::AppearController do
  let!(:topic) { create :topic }

  let(:user2) { create :user }
  let(:user3) { create :user }

  let!(:comment) { create :comment, commentable_id: topic.id, commentable_type: topic.class.name, user_id: user2.id }
  let!(:comment2) { create :comment, commentable_id: topic.id, commentable_type: topic.class.name }

  describe '#create' do
    let(:user) { create :user }

    it 'not authorized' do
      expect {
        post :create, ids: "comment-#{comment.id}"
      }.to change(CommentViewing, :count).by 0

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
          post :create, ids: "comment-#{comment.id}"
        }.to change(CommentViewing, :count).by 1
      end

      it 'multiple views', :show_in_doc do
        expect {
          expect {
            post :create, ids: "comment-#{comment.id},comment-#{comment2.id},topic-#{topic.id}"
          }.to change(CommentViewing, :count).by 2
        }.to change(TopicViewing, :count).by 1
      end

      it 'only once' do
        expect {
          post :create, ids: "comment-#{comment.id}"
          post :create, ids: "comment-#{comment.id}"
        }.to change(CommentViewing, :count).by 1
      end

      it 'no views for not existing' do
        expect {
          post :create, ids: 'comment-999999'
        }.to change(CommentViewing, :count).by 0
      end

      it '"reads" comment notification message' do
        original_comment = create :comment, commentable: topic, user: user
        reply_comment = nil

        # создаём ответ на комментарий
        expect {
          reply_comment = create(
            :comment,
            :with_notify_quotes,
            commentable: topic,
            user: user3,
            body: "[comment=#{original_comment.id}]ня[/comment]"
          )
        }.to change(Message, :count).by 1

        # должно создаться уведомление о новом комменте
        message = Message.last
        expect(message.read).to be_falsy
        expect(message.from_id).to eq user3.id
        expect(message.to_id).to eq user.id
        expect(message.kind).to eq MessageType::QuotedByUser

        post :create, ids: "comment-#{reply_comment.id}", log: true

        # то самое уведомление должно стать прочитанным
        message = Message.find(message.id)
        expect(message.read).to eq true
      end
    end
  end
end
