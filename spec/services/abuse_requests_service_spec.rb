describe AbuseRequestsService do
  let(:service) do
    AbuseRequestsService.new(
      comment: comment,
      topic: topic,
      reporter: user_reporter
    )
  end
  let!(:user_reporter) { create :user, id: 99 }

  let(:comment) do
    create :comment, :skip_cancel_summary,
      user: user_author,
      is_offtopic: is_offtopic,
      is_summary: is_summary,
      created_at: created_at,
      commentable: commentable
  end
  let(:is_offtopic) { false }
  let(:is_summary) { false }
  let(:created_at) { Time.zone.now }
  let(:commentable) { seed :offtopic_topic }
  let(:user_author) { seed :user }
  let(:user_reporter) { user_author }

  let(:topic) { nil }

  let(:faye_token) { 'test' }

  describe '#offtopic' do
    subject(:act) { service.offtopic faye_token }

    describe 'add offtopic' do
      context 'allowed direct change' do
        it do
          expect { act }.to_not change AbuseRequest, :count
          is_expected.to eq [comment.id]
          expect(comment).to be_offtopic
        end
      end
    end

    describe 'remove offtopic' do
      let(:is_offtopic) { true }

      context 'user' do
        context 'old comment' do
          let(:created_at) { 1.month.ago }
          it do
            expect { act }.to change(AbuseRequest, :count).by 1
            expect(comment).to be_offtopic
          end
        end

        context 'new comment' do
          it do
            expect { act }.to_not change AbuseRequest, :count
            expect(comment).to_not be_offtopic
          end
        end
      end

      context 'moderator' do
        let(:user_reporter) { create :user, :forum_moderator }
        it do
          expect { act }.to change(AbuseRequest, :count).by 1
          expect(comment).to_not be_offtopic
        end

        context 'already present abuse_request' do
          let!(:abuse_request) do
            create :abuse_request,
              state: :pending,
              comment: comment,
              kind: :offtopic,
              value: false
          end

          it do
            expect { act }.to_not change AbuseRequest, :count
            expect(comment).to_not be_offtopic
            expect(abuse_request.reload).to be_accepted
          end
        end
      end
    end
  end

  describe '#convert_review' do
    subject(:act) { service.convert_review faye_token }

    let!(:anime_topic) { create :anime_topic, linked: anime }
    let(:anime) { create :anime }

    context 'converting comment' do
      let(:commentable) { anime_topic }

      context 'allowed direct change', :focus do
        it do
          expect { act }.to_not change AbuseRequest, :count
          expect { comment.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'not allowed direct change' do
        let(:created_at) { 1.month.ago }

        context 'user' do
          it do
            expect { act }.to change(AbuseRequest, :count).by 1
            expect(comment.reload).to be_persisted
          end
        end
      end
    end

    context 'converting review' do
      let(:comment) { nil }
      let(:review) { create :review, anime: anime, user: user_author }
      let(:topic) do
        create :review_topic,
          linked: review,
          user: user_author,
          created_at: created_at
      end

      context 'allowed direct change' do
        it do
          expect { act }.to_not change AbuseRequest, :count
          expect { review.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'not allowed direct change' do
        let(:created_at) { 1.month.ago }

        context 'user' do
          it do
            expect { act }.to change(AbuseRequest, :count).by 1
            expect(review.reload).to be_persisted
          end
        end
      end
    end
  end

  allowed_actions = {
    topic: %i[abuse spoiler],
    review: %i[convert_review abuse spoiler],
    comment: %i[offtopic convert_review abuse spoiler]
  }
  faye_token_methods = %i[convert_review offtopic]

  %i[offtopic convert_review abuse spoiler].each do |method|
    describe "##{method}" do
      let(:reason) { 'zxcvbn' unless faye_token_methods.include? method }
      subject(:act) do
        service.send(
          method,
          faye_token_methods.include?(method) ? faye_token : reason
        )
      end
      let(:user_reporter) { create :user, id: 99 }

      %i[comment topic].each do |type| # rubocop:disable CollectionLiteralInLoop
        context type.to_s do
          let(:comment) { create :comment, user: user_author if type == :comment }
          let(:review) { create :review, user: user_author, anime: anime }
          let(:topic) do
            case type
              when :topic
                create :topic, user: user_author
              when :review
                create :review_topic, user: user_author, linked: review
            end
          end
          let(:anime) { create :anime }

          if allowed_actions[type].exclude? method
            it do
              expect { act }.to raise_error CanCan::AccessDenied
            end
          else
            it do
              expect { act }.to change(AbuseRequest, :count).by 1
            end

            describe 'abuse_request' do
              before { act }
              subject { user_reporter.abuse_requests.last }

              it do
                expect(subject).to have_attributes(
                  kind: method.to_s,
                  value: method != :convert_review || type == :comment,
                  comment_id: (comment.id if type == :comment),
                  topic_id: (topic.id if type.in? %i[topic review]),
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
