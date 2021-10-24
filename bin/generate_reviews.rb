#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

ActiveRecord::Base.logger.level = 3;
if Rails.env.development?
  # reload!
  puts 'Destroying all reviews...'
  Chewy.strategy(:atomic) { Review.destroy_all }
else
  raise RuntimeError
end

[Anime, Manga].each do |klass|
  puts "Fetching #{klass.name.downcase} scores..."
  normalization = Recommendations::Normalizations::ZScoreCentering.new;
  rates_fetcher = Recommendations::RatesFetcher.new(klass);

  puts 'Generating reviews...'
  Comment.
    includes(:user, commentable: :linked).
    where(is_summary: true).
    order(id: :desc).
    # limit(1000).where(commentable_id: [Anime.find(5081).decorate.main_topic_view.id, Anime.find(31240).decorate.main_topic_view.id, Manga.find(2).decorate.main_topic_view.id, Ranobe.find(9115).decorate.main_topic_view.id]).
    limit(1000).where(commentable_id: [Manga.find(2).decorate.main_topic_view.id]).
    find_each do |comment|
      db_entry = comment.commentable.linked
      next if db_entry.class.base_class != klass

      Review.wo_antispam do
        Chewy.strategy(:atomic) do
          Comment::ConvertToReview.call comment,
            normalization: normalization,
            rates_fetcher: rates_fetcher,
            is_keep_comment: Rails.env.development?
        end
        # ap review
      rescue ActiveRecord::RecordInvalid
        raise unless review.errors[:user_id].present?
      end
    end;
end;
