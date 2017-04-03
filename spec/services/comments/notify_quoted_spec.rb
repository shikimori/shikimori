describe Comments::NotifyQuoted do
  let(:service) do
    Comments::NotifyQuoted.new(
      old_body: old_body,
      new_body: new_body,
      comment: comment,
      user: comment_owner
    )
  end
  subject { service.call }

  let(:quoted_user) { create :user }
  let(:comment_owner) { comment.user }
  let(:comment) { create :comment }

  let(:old_body) { '' }
  let(:new_body) { "[quote=200778;#{quoted_user.id};test2]test[/quote]" }

  describe 'quote types' do
    context 'quote' do
      let(:new_body) { "[quote=200778;#{quoted_user.id};test2]test[/quote]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'comment' do
      let!(:comment_2) { create :comment }
      let(:new_body) { "[comment=#{comment_2.id}]test[/comment]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'topic' do
      let(:topic) { create :topic, user: quoted_user }
      let(:new_body) { "[topic=#{topic.id}]test[/topic]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'mention' do
      let(:new_body) { "[mention=#{quoted_user.id}]test[/mention]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end
  end

  context 'quote by ignored user' do
    before { quoted_user.ignored_users << comment_owner }
    it { expect { subject }.to_not change Message, :count }
  end

  context 'single quote' do
    let(:new_body) do
      <<~TEXT
        [quote=888888;#{quoted_user.id};test2]test[/quote]
      TEXT
    end
    it do
      expect { subject }.to change(Message, :count).by 1
      expect(quoted_user.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QuotedByUser,
        linked: comment
      )
    end
  end

  context 'multiple quotes' do
    let(:quoted_user_1) { create :user }
    let(:quoted_user_2) { create :user }

    let(:new_body) do
      <<~TEXT
        [quote=888888;#{quoted_user_1.id};test2]test[/quote]
        [quote=999999;#{quoted_user_2.id};test2]test[/quote]
      TEXT
    end
    it do
      expect { subject }.to change(Message, :count).by 2
      expect(quoted_user_1.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QuotedByUser,
        linked: comment
      )
      expect(quoted_user_2.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QuotedByUser,
        linked: comment
      )
    end
  end

  context 'same user quotes' do
    let(:new_body) do
      <<~TEXT
        [quote=888888;#{quoted_user.id};test2]test[/quote]
        [quote=999999;#{quoted_user.id};test2]test[/quote]
      TEXT
    end
    it { expect { subject }.to change(Message, :count).by 1 }
  end

  context 'with notification exists' do
    let!(:message) do
      create :message,
        to: quoted_user,
        from: comment_owner,
        kind: MessageType::QuotedByUser,
        linked: comment
    end
    it { expect { subject }.to_not change Message, :count }

    context 'removed quote' do
      let(:old_body) { "[quote=200778;#{quoted_user.id};test2]test[/quote]" }
      let(:new_body) { '' }

      let!(:message) do
        create :message,
          to: quoted_user,
          from: comment_owner,
          kind: MessageType::QuotedByUser,
          linked: comment
      end

      it { expect { subject }.to change(Message, :count).by(-1) }
    end
  end
end
