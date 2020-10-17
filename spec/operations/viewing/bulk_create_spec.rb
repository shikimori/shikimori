# frozen_string_literal: true

describe Viewing::BulkCreate do
  subject(:call) do
    Viewing::BulkCreate.call(
      user: user,
      viewed_klass: viewed_klass,
      viewed_ids: viewed_ids
    )
  end

  shared_examples_for :viewed do
    context '1 viewed id' do
      let(:viewed_ids) { [viewed_1.id] }
      it { expect { call }.to change(viewing_klass, :count).by 1 }
    end

    context '2 different viewed ids' do
      let(:viewed_ids) { [viewed_1.id, viewed_2.id] }
      it { expect { call }.to change(viewing_klass, :count).by 2 }
    end

    context '2 same viewed ids' do
      let(:viewed_ids) { [viewed_1.id, viewed_1.id] }
      it { expect { call }.to change(viewing_klass, :count).by 1 }
    end

    context 'not existing viewed id' do
      let(:viewed_ids) { [99_999] }
      it { expect { call }.not_to change(viewing_klass, :count) }
    end

    context 'with existing viewing for viewed id' do
      before { viewing_klass.create user: user, viewed: viewed_1 }
      let(:viewed_ids) { [viewed_1.id, viewed_2.id] }
      it { expect { call }.to change(viewing_klass, :count).by 1 }
    end
  end

  context 'Topic' do
    it_behaves_like :viewed do
      let(:viewed_klass) { Topic }
      let(:viewing_klass) { TopicViewing }

      let!(:viewed_1) { create :topic }
      let!(:viewed_2) { create :topic }
    end
  end

  context 'Comment' do
    it_behaves_like :viewed do
      let(:viewed_klass) { Comment }
      let(:viewing_klass) { CommentViewing }

      let!(:viewed_1) { create :comment }
      let!(:viewed_2) { create :comment }
    end
  end

  describe 'reading inbox messages' do
    subject { Message.where(to_id: user.id).first }

    let(:topic) { create :topic }
    let!(:original_comment) do
      create :comment, commentable: topic, user: user
    end
    let!(:reply_comment) do
      create(
        :comment,
        :with_notify_quoted,
        commentable: topic,
        user: create(:user),
        body: "[comment=#{original_comment.id}]ня[/comment]"
      )
    end

    let(:viewed_klass) { Comment }
    let(:viewed_ids) { [reply_comment.id] }

    before { call }
    it { is_expected.to be_read }
  end
end
