# frozen_string_literal: true

describe Viewing::BulkCreate do
  subject(:call) { operation.call user, viewed_klass, viewed_ids }
  let(:operation) { Viewing::BulkCreate.new }

  let(:user) { create :user }

  shared_examples_for :viewed do
    context '1 id' do
      let(:viewed_ids) { [viewed_1.id] }
      it { expect { call }.to change(viewing_klass, :count).by 1 }
    end

    context '2 different ids' do
      let(:viewed_ids) { [viewed_1.id, viewed_2.id] }
      it { expect { call }.to change(viewing_klass, :count).by 2 }
    end

    context '2 same ids' do
      let(:viewed_ids) { [viewed_1.id, viewed_1.id] }
      it { expect { call }.to change(viewing_klass, :count).by 1 }
    end

    context 'not existing id' do
      let(:viewed_ids) { [99_999] }
      it { expect { call }.not_to change(viewing_klass, :count) }
    end

    context 'with existing viewing for id' do
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
end
