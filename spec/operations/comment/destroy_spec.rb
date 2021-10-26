describe Comment::Destroy do
  subject { described_class.call comment, faye }

  let!(:comment) do
    create :comment, :with_increment_comments, :with_decrement_comments,
      commentable: topic
  end
  let(:faye) { FayeService.new user, nil }
  let(:topic) { create :topic, created_at: topic_created_at }
  let(:topic_created_at) { 1.month.ago }

  context 'last comment of a topic' do
    it do
      expect { subject }.to change(Comment, :count).by(-1)
      expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(topic.reload.updated_at).to be_within(0.1).of(topic_created_at)
    end
  end

  context 'not last comment of a topic' do
    let!(:topic_comment_1) do
      create :comment, :with_increment_comments,
        commentable: topic,
        created_at: 15.days.ago
    end
    let!(:topic_comment_2) do
      create :comment, :with_increment_comments,
        commentable: topic,
        created_at: 10.days.ago
    end

    it do
      expect { subject }.to change(Comment, :count).by(-1)
      expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(topic.reload.updated_at).to be_within(0.1).of(topic_comment_2.created_at)
    end
  end
end
