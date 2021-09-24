#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

ActiveRecord::Base.logger.level = 3;
if Rails.env.development?
  # reload!
  puts 'Destroying all reviews...'
  Review.destroy_all
else
  raise RuntimeError
end

def cut_system_bbcodes text
  text.gsub(/\[(?:replies|ban)=[\d,]+\]/, '').strip
end

[Anime, Manga].each do |klass|
  puts "Fetching #{klass.name.downcase} scores..."
  normalization = Recommendations::Normalizations::ZScoreCentering.new;
  rates_fetcher = Recommendations::RatesFetcher.new(klass);
  review = nil;

  puts 'Generating reviews...'
  Comment.
    includes(:user, commentable: :linked).
    where(is_summary: true).
    order(id: :desc).
    limit(1000).where(commentable_id: Anime.find(31240).decorate.main_topic_view.id).
    find_each do |comment|
      db_entry = comment.commentable.linked
      next if db_entry.class.base_class != klass

      user = comment.user

      rates_fetcher.user_ids = [user.id]
      rates_fetcher.user_cache_key = user.cache_key_with_version
      rates = rates_fetcher.fetch(normalization)

      normalized_score = rates.dig(user.id, db_entry.id)

      opinion =
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

      is_written_before_release =
        if (db_entry.released? && !db_entry.released_on) || (db_entry.is_a?(Manga) && db_entry.discontinued?)
          false
        elsif db_entry.ongoing? || db_entry.anons? || (db_entry.is_a?(Manga) && db_entry.paused?)
          true
        elsif db_entry.released? && db_entry.released_on?
          comment.created_at < db_entry.released_on
        else
          raise "unexpected db_entry state"
        end

      is_dropped = UserRate.find_by(target: db_entry, user: user)&.dropped?
      if is_dropped
        opinion = Types::Review::Opinion[:negative]
        ap "dropped #{opinion} #{is_written_before_release}"
      else
        ap "#{normalized_score} #{opinion} #{is_written_before_release}"
      end

      review = Review.new(
        user: user,
        body: cut_system_bbcodes(comment.body),
        anime: (db_entry if db_entry.anime?),
        manga: (db_entry if db_entry.manga? || db_entry.ranobe?),
        opinion: opinion,
        is_written_before_release: is_written_before_release,
        created_at: comment.created_at
      )
      review.instance_variable_set :@is_migration, true
      Review.wo_antispam do
        review.save!
        # ap review
      rescue ActiveRecord::RecordInvalid
        raise unless review.errors[:user_id].present?
      end
    end;
end;
