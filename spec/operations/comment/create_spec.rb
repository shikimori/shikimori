describe Comment::Create do
  include_context :timecop
  subject(:comment) do
    described_class.call(
      params: params,
      faye: faye,
      is_conversion: is_conversion,
      is_forced: is_forced
    )
  end

  let(:anime) { create :anime }
  let!(:topic) do
    create :anime_topic,
      user: user,
      linked: anime,
      updated_at: 1.hour.ago
  end

  let(:faye) { FayeService.new user, nil }
  let(:params) do
    {
      commentable_id: commentable_id,
      commentable_type: commentable_type,
      body: 'xx',
      is_offtopic: is_offtopic,
      user: user
    }
  end
  let(:is_offtopic) { [true, false].sample }
  let(:is_conversion) { nil }
  let(:is_forced) { nil }

  before { allow_any_instance_of(FayePublisher).to receive :publish }

  shared_examples_for :comment do
    it do
      expect(comment).to be_persisted
      expect(comment).to have_attributes(
        commentable_type: Topic.name,
        body: 'xx',
        is_offtopic: is_offtopic,
        user: user
      )
    end
  end

  # TODO: cannot pass arbitrary topic class
  #       because of limit on commentable_type in comments
  describe 'commentable' do
    context 'commentable is topic' do
      let(:commentable_id) { topic.id }
      let(:commentable_type) { Topic.name }

      it_behaves_like :comment
      it do
        expect(comment.topic).to eq topic
        expect(comment.topic.updated_at).to be_within(0.1).of(Time.zone.now)
      end
    end

    context 'commentable is user' do
      let(:commentable_id) { user.id }
      let(:commentable_type) { User.name }
      before { allow(User::NotifyProfileCommented).to receive :call }

      it do
        expect(comment).to have_attributes(
          commentable: user,
          body: 'xx',
          is_offtopic: is_offtopic,
          user: user
        )
        expect(User::NotifyProfileCommented)
          .to have_received(:call)
          .with comment
      end
    end

    context 'commentable is review' do
      let(:review) { create :review, anime: anime }
      let(:anime) { create :anime }
      let(:commentable_id) { review.id }
      let(:commentable_type) { Review.name }

      it do
        expect(comment).to have_attributes(
          commentable: review,
          body: 'xx',
          is_offtopic: is_offtopic,
          user: user
        )
      end
    end

    context 'commentable is db entry' do
      let(:commentable_id) { anime.id }
      let(:commentable_type) { Anime.name }

      context 'with topic' do
        it_behaves_like :comment
        it do
          expect(subject.topic).to eq topic
          expect(subject.updated_at).to be_within(0.1).of Time.zone.now
        end
      end

      context 'without topic' do
        let(:topic) { nil }

        # it_behaves_like :comment
        it 'creates anime topic with specified locale' do
          expect(subject.topic).to have_attributes(
            type: Topics::EntryTopics::AnimeTopic.name
          )
          expect(subject.topic.created_at).to be_within(0.1).of Time.zone.now
          expect(subject.topic.updated_at).to be_within(0.1).of Time.zone.now
        end
      end

      describe 'is_forced' do
        context 'invalid params' do
          let(:commentable_type) { nil }

          context 'not forced' do
            it do
              is_expected.to be_new_record
              is_expected.to_not be_valid
            end
          end

          context 'forced' do
            let(:is_forced) { true }
            it { expect { subject }.to raise_error ActiveRecord::RecordInvalid }
          end
        end
      end

      describe 'is_conversion' do
        let(:is_conversion) { [true, false].sample }
        it { expect(subject.instance_variable_get(:@is_conversion)).to eq is_conversion }
      end
    end
  end
end
