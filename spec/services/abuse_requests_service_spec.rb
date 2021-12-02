describe AbuseRequestsService do
  let(:service) do
    AbuseRequestsService.new(
      comment: comment,
      topic: topic,
      review: review,
      reporter: user_reporter
    )
  end
  let!(:user_reporter) { create :user, id: 99 }

  let(:comment) do
    create :comment, :skip_cancel_summary,
      user: user_author,
      is_offtopic: is_offtopic,
      is_summary: is_summary,
      created_at: created_at
  end
  let(:is_offtopic) { false }
  let(:is_summary) { false }
  let(:created_at) { Time.zone.now }
  let(:user_author) { seed :user }
  let(:user_reporter) { user_author }

  let(:topic) { nil }
  let(:review) { nil }

  let(:faye_token) { 'test' }

  describe '#offtopic' do
    subject(:act) { service.offtopic faye_token }

    it do
      expect { act }.to change(AbuseRequest, :count).by 1
      is_expected.to eq [comment.id]
    end

    describe 'offtopic?' do
      before { act }
      subject { comment.offtopic? }
      it { is_expected.to eq true }
    end

    describe 'cancel' do
      let(:is_offtopic) { true }

      context 'user' do
        context 'old comment' do
          let(:created_at) { 1.month.ago }
          it { expect { act }.to change(AbuseRequest, :count).by 1 }
        end

        context 'new comment' do
          it { expect { act }.to change(AbuseRequest, :count).by 1 }
        end
      end

      context 'moderator' do
        let(:created_at) { 1.month.ago }
        let(:user_reporter) { create :user, :forum_moderator }
        it do
          expect { act }.to change(AbuseRequest, :count).by 1
        end
      end
    end
  end

  describe '#summary' do
    subject(:act) { service.summary faye_token }

    context 'new comment' do
      let(:created_at) { 4.minutes.ago }

      it do
        expect { act }.to change(AbuseRequest, :count).by 1
        is_expected.to eq [comment.id]
        expect(comment).to be_summary
      end

      describe 'cancel' do
        let(:is_summary) { true }

        it do
          expect { act }.to change(AbuseRequest, :count).by 1
          is_expected.to eq [comment.id]
          expect(comment).not_to be_summary
        end
      end
    end

    context 'old comment' do
      let(:created_at) { 6.minutes.ago }

      it do
        expect { act }.to change AbuseRequest, :count
        is_expected.to eq []
        expect(comment).to_not be_summary
      end
    end
  end

  comment_actions = %i[summary offtopic]
  %i[summary offtopic abuse spoiler].each do |method|
    describe method.to_s do
      if comment_actions.include? method
        let(:reason) { nil }
        subject(:act) { service.send method, faye_token }
      else
        let(:reason) { 'zxcvbn' }
        subject(:act) { service.send method, reason }
      end
      let(:user_reporter) { create :user, id: 99 }

      %i[comment topic review].each do |type| # rubocop:disable CollectionLiteralInLoop
        context type.to_s do
          let(:comment) { create :comment, user: user_author if type == :comment }
          let(:review) { create :review, user: user_author, anime: anime if type == :review }
          let(:topic) { create :topic, user: user_author if type == :topic }
          let(:anime) { create :anime }

          if type != :comment && comment_actions.include?(method)
            it do
              expect { act }.to raise_error CanCan::AccessDenied
            end
          else
            it do
              expect { act }.to change(AbuseRequest, :count).by 1
              is_expected.to eq []
            end

            describe 'abuse_request' do
              before { act }
              subject { user_reporter.abuse_requests.last }

              it do
                expect(subject).to have_attributes(
                  kind: method.to_s,
                  value: true,
                  comment_id: (comment.id if type == :comment),
                  review_id: (review.id if type == :review),
                  topic_id: (topic.id if type == :topic),
                  reason: reason
                )
              end
            end

            context 'already acted' do
              before { act }
              it { expect { act }.to change(AbuseRequest, :count).by 0 }
            end
          end
        end
      end
    end
  end
end
