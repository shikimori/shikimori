class Comment::ConvertToReview
  method_object :comment, %i[normalization rates_fetcher]
  delegate :user, to: :comment

  def call
    review = build_review
    review.instance_variable_set :@is_migration, true

    Review.wo_antispam { review.save! }
    comment.destroy!

    Rails.logger.convert_to_review review.to_json

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
      created_at: comment.created_at
    )
  end

  def db_entry
    @comment.commentable.linked
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
