describe User::NotifyProfileCommented do
  subject { described_class.call comment }

  let(:comment) do
    create :comment,
      user: comment_user,
      commentable: commentable
  end
  let(:commentable) { user }
  let(:comment_user) { user_2 }

  let(:message_scope) do
    Message.where(
      to_id: user.id,
      from_id: comment_user.id,
      kind: described_class::MESSAGE_KIND
    )
  end

  it do
    expect { subject }.to change(message_scope, :count).by 1
  end

  context 'non profile comment' do
    let(:commentable) { offtopic_topic }
    it do
      expect { subject }.to raise_error ArgumentError, "non profile comment##{comment.id}"
    end
  end

  context 'own profile' do
    let(:comment_user) { user }
    it do
      expect { subject }.to_not change message_scope, :count
      is_expected.to be_nil
    end
  end

  context 'has unread notification' do
    let!(:message) do
      create :message,
        to_id: to_id,
        from_id: from_id,
        kind: kind
    end
    let(:to_id) { user.id }
    let(:from_id) { comment_user.id }
    let(:kind) { described_class::MESSAGE_KIND }

    it do
      expect { subject }.to_not change message_scope, :count
      is_expected.to be_nil
    end

    context 'from another user' do
      let(:from_id) { user_3.id }
      it do
        expect { subject }.to change(message_scope, :count).by 1
      end
    end

    context 'to another user' do
      let(:to_id) { user_3.id }
      it do
        expect { subject }.to change(message_scope, :count).by 1
      end
    end

    context 'another message kind' do
      let(:kind) { MessageType::PRIVATE }

      it do
        expect { subject }.to change(message_scope, :count).by 1
      end
    end
  end
end
