class Comment::ConvertToReview
  method_object %i[
    comment
    actor
    normalization
    rates_fetcher
    is_keep_comment
  ]
  delegate :user, to: :comment

  def call # rubocop:disable MethodLength, AbcSize
    review = build_review
    review.instance_variable_set :@is_conversion, true

    ApplicationRecord.transaction do
      Review.wo_antispam { review.save! }
      review.generate_topic if review.persisted?
      review_topic = review.maybe_topic

      unless @is_keep_comment
        Comments::Move.call(
          comment_ids: replies_ids,
          commentable: review_topic,
          from_reply: @comment,
          to_reply: review_topic
        )

        close_offtopic_abuse_requests
        accept_convert_to_review_abuse_requests
        move_abuse_requests_and_bans review_topic
        @comment.destroy!
      end

      NamedLogger.convert_to_review.info review.to_json
    end

    review
  end

private

  def build_review
    Review.new(
      user: user,
      body: cut_system_bbcodes(@comment.body),
      anime: (db_entry if db_entry.anime?),
      manga: (db_entry if db_entry.manga? || db_entry.ranobe?),
      opinion: opinion,
      created_at: @comment.created_at,
      updated_at: @comment.updated_at
    )
  end

  def close_offtopic_abuse_requests
    @comment.abuse_requests
      .where(state: :pending)
      .where(kind: Types::AbuseRequest::Kind[:offtopic])
      .each do |abuse_request|
        abuse_request.reject! approver: @actor
      end
  end

  def accept_convert_to_review_abuse_requests
    @comment.abuse_requests
      .where(state: :pending)
      .where(kind: Types::AbuseRequest::Kind[:convert_review])
      .each do |abuse_request|
        abuse_request.accept! approver: @actor, is_process_in_faye: false
      end
  end

  def move_abuse_requests_and_bans review_topic
    @comment.abuse_requests.update_all comment_id: nil, topic_id: review_topic.id
    @comment.bans.update_all comment_id: nil, topic_id: review_topic.id
  end

  def db_entry
    @comment.commentable.linked
  end

  def replies_ids
    Comments::RepliesByBbCode
      .call(
        model: @comment,
        commentable: @comment.commentable
      )
      .map(&:id)
  end

  def opinion
    return Types::Review::Opinion[:negative] if dropped?

    normalized_score = fetch_score

    if normalized_score
      if normalized_score >= 0.095
        Types::Review::Opinion[:positive]
      elsif normalized_score <= -0.14
        Types::Review::Opinion[:negative]
      else
        Types::Review::Opinion[:neutral]
      end
    else
      Types::Review::Opinion[:neutral]
    end
  end

  def cut_system_bbcodes text
    # text.gsub(/\[(?:replies|ban)=[\d,]+\]/, '').strip
    text.gsub(/\[(?:ban)=[\d,]+\]/, '').strip
  end

  def fetch_score
    rates_fetcher.user_ids = [user.id]
    rates_fetcher.user_cache_key = user.cache_key_with_version
    rates = rates_fetcher.fetch(normalization)
    rates.dig user.id, db_entry.id
  end

  def dropped?
    !!UserRate.find_by(target: db_entry, user: user)&.dropped?
  end

  def normalization
    @normalization ||= Recommendations::Normalizations::ZScoreCentering.new
  end

  def rates_fetcher
    @rates_fetcher ||= Recommendations::RatesFetcher.new db_entry.class.base_class
  end
end
