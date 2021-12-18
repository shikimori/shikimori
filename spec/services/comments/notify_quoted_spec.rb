describe Comments::NotifyQuoted do
  let(:service) do
    Comments::NotifyQuoted.new(
      old_body: old_body,
      new_body: new_body,
      comment: comment,
      user: comment_owner.decorate
    )
  end
  subject { service.call }

  let(:quoted_user) { create :user }
  let(:comment_owner) { comment.user }
  let(:comment) { create :comment }
  let(:quoted_comment) { create :comment, body: 'zzz', user: quoted_user }

  let(:old_body) { '' }
  let(:new_body) { "[quote=200778;#{quoted_user.id};test2]test[/quote]" }

  describe 'quote types' do
    context 'quote' do
      context 'simple' do
        let(:new_body) { "[quote=9999999;#{quoted_user.id};test2]test[/quote]" }
        it do
          expect { subject }.to change(Message, :count).by 1
          expect(quoted_comment.reload.body).to eq 'zzz'
        end
      end

      context 'comment' do
        let(:new_body) { "[quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]" }
        it do
          expect { subject }.to change(Message, :count).by 1
          expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
        end
      end

      context 'own comment' do
        let(:quoted_user) { comment_owner }
        let(:new_body) { "[quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]" }
        it do
          expect { subject }.to_not change Message, :count
          expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
        end
      end

      context 'user mention' do
        let(:new_body) { "@#{quoted_user.nickname}, test" }
        it { expect { subject }.to change(Message, :count).by 1 }
      end
    end

    context 'comment' do
      let(:new_body) { "[comment=#{quoted_comment.id}]test[/comment]" }

      context 'simple' do
        it do
          expect { subject }.to change(Message, :count).by 1
          expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
        end
      end

      context 'own comment' do
        let(:quoted_user) { comment_owner }
        it do
          expect { subject }.to_not change Message, :count
          expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
        end
      end
    end

    context 'topic' do
      let(:topic) { create :topic, user: quoted_user }
      let(:new_body) { "[topic=#{topic.id}]test[/topic]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'review' do
      let(:review) { create :review, user: quoted_user, anime: create(:anime) }
      let(:new_body) { "[review=#{review.id}]test[/review]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'mention' do
      let(:new_body) { "[mention=#{quoted_user.id}]test[/mention]" }
      it { expect { subject }.to change(Message, :count).by 1 }
    end

    context 'self quote' do
      let(:new_body) { "[mention=#{comment_owner.id}]test[/mention]" }
      it { expect { subject }.to_not change Message, :count }
    end
  end

  context 'quote by ignored user' do
    before { quoted_user.ignored_users << comment_owner }
    it { expect { subject }.to_not change Message, :count }
  end

  context 'mention to user with disabled mention notifications' do
    before do
      quoted_user.update!(
        notification_settings: quoted_user.notification_settings.values - [
          Types::User::NotificationSettings[:mention_event].to_s
        ]
      )
    end
    it { expect { subject }.to_not change Message, :count }
  end

  context 'mention to user with enabled mention notifications' do
    before { user.notification_settings << Types::User::NotificationSettings[:mention_event] }
    it { expect { subject }.to change Message, :count }
  end

  context 'single quote' do
    let(:new_body) do
      <<~TEXT
        [quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]
      TEXT
    end
    it do
      expect { subject }.to change(Message, :count).by 1
      expect(quoted_user.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QUOTED_BY_USER,
        linked: comment
      )
      expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
    end
  end

  context 'multiple quotes' do
    let(:quoted_comment_1) { create :comment, user: quoted_user_1, body: 'xxx' }
    let(:quoted_comment_2) { create :comment, user: quoted_user_2, body: 'ccc' }
    let(:quoted_user_1) { create :user }
    let(:quoted_user_2) { create :user }

    let(:new_body) do
      <<~TEXT
        [quote=c#{quoted_comment_1.id};#{quoted_user_1.id};test2]test[/quote]
        [quote=c#{quoted_comment_2.id};#{quoted_user_2.id};test3]test[/quote]
      TEXT
    end
    it do
      expect { subject }.to change(Message, :count).by 2
      expect(quoted_user_1.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QUOTED_BY_USER,
        linked: comment
      )
      expect(quoted_user_2.messages.first).to have_attributes(
        from_id: comment_owner.id,
        kind: MessageType::QUOTED_BY_USER,
        linked: comment
      )
      expect(quoted_comment_1.reload.body).to eq "xxx\n\n[replies=#{comment.id}]"
      expect(quoted_comment_2.reload.body).to eq "ccc\n\n[replies=#{comment.id}]"
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

    context 'same comment quotes' do
      let(:new_body) do
        <<~TEXT
          [quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]
          [quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]
        TEXT
      end
      it do
        expect { subject }.to change(Message, :count).by 1
        expect(quoted_comment.reload.body).to eq "zzz\n\n[replies=#{comment.id}]"
      end
    end
  end

  context 'with notification exists' do
    let!(:message) do
      create :message,
        to: quoted_user,
        from: comment_owner,
        kind: MessageType::QUOTED_BY_USER,
        linked: comment
    end
    it { expect { subject }.to_not change Message, :count }

    context 'removed quote' do
      let(:quoted_comment) do
        create :comment,
          body: "zzz\n\n[replies=#{comment.id}]",
          user: quoted_user
      end
      let(:old_body) { "[quote=c#{quoted_comment.id};#{quoted_user.id};test2]test[/quote]" }
      let(:new_body) { '' }

      let!(:message) do
        create :message,
          to: quoted_user,
          from: comment_owner,
          kind: MessageType::QUOTED_BY_USER,
          linked: comment
      end

      it do
        expect { subject }.to change(Message, :count).by(-1)
        expect(quoted_comment.reload.body).to eq 'zzz'
      end
    end

    context 'changed quote' do
      let(:quoted_comment_1) do
        create :comment,
          body: "zzz\n\n[replies=#{comment.id}]",
          user: quoted_user
      end
      let(:quoted_comment_2) do
        create :comment,
          body: 'xxx',
          user: another_user
      end
      let(:another_user) { create :user }
      let(:old_body) { "[quote=c#{quoted_comment_1.id};#{quoted_user.id};test2]test[/quote]" }
      let(:new_body) { "[quote=c#{quoted_comment_2.id};#{another_user.id};test2]test[/quote]" }

      let!(:message) do
        create :message,
          to: quoted_user,
          from: comment_owner,
          kind: MessageType::QUOTED_BY_USER,
          linked: comment
      end

      it do
        expect { subject }.to_not change Message, :count
        expect { message.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(another_user.messages.first).to have_attributes(
          from_id: comment_owner.id,
          kind: MessageType::QUOTED_BY_USER,
          linked: comment
        )
        expect(quoted_comment_1.reload.body).to eq 'zzz'
        expect(quoted_comment_2.reload.body).to eq "xxx\n\n[replies=#{comment.id}]"
      end
    end
  end
end
