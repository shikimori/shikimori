# rubocop:disable ClassLength
class FixAnimeVideoAuthors
  include Sidekiq::Worker
  include ActionView::Helpers::TextHelper

  TRASH = /[^\[\]() &,-]{0,4}/.source
  STUDIOS = %w(
    AniDUB AniStar AniLibria SHIZA AnimeReactor AnimeVost AniPlay AniRecords
    AniUchi AniSound AnimeReactor NekoProject AnimeJet FreeDub AniFame AniChaos
    RainDub
  ) + [
    'DeadLine Studio', 'Bastion Studio', 'Onibaku Group'
  ]
  QUALITIES = AnimeVideo.quality.values.reject { |v| v == 'unknown' }

  STUDIOS_REPLACEMENTS = STUDIOS.each_with_object({}) do |name, memo|
    memo[/
      (?: \( \s* )?
        (?: \b#{TRASH} )?
        #{name}
        #{TRASH}
        (?! [&-] )
      (?: \s* \) )?
    /mix] = name
  end
  STUDIOS_REPOSITIONS = STUDIOS.each_with_object({}) do |name, memo|
    memo[/
      \A
      (?: \( \s* )? ([^()]+) (?: \s* \) )?
      \s
      (?: \( \s* )? (#{name}) (?: \s* \) )?
      \Z
    /mix] = '\2 (\1)'

    memo[/
      \A
      (?: \( \s* )? (#{name}) (?: \s* \) )?
      \s
      (?: \( \s* )? ([^()]+) (?: \s* \) )?
      \Z
    /mix] = '\1 (\2)'
  end

  QUALITIES_REPLACEMENTS = QUALITIES.each_with_object({}) do |name, memo|
    memo[name] = /
      \A
      (?: [\[(] \s* )?
        \b#{name}\b
        #{TRASH}
        (?! [&-] )
      (?: \s* [\])]+ )?
    /mix
  end

  JOIN_SQL = <<-TEXT.strip
    left join anime_videos
      on anime_videos.anime_video_author_id = anime_video_authors.id
TEXT

  def perform
    AnimeVideo.transaction do
      process
      cleanup
    end
  end

private

  def cleanup
    ids = AnimeVideoAuthor
      .joins(JOIN_SQL)
      .where('anime_videos.id is null')
      .select('anime_video_authors.id')

    AnimeVideoAuthor.where(id: ids).delete_all
  end

  def process
    authors.each do |author|
      quality = match_quality(author.name)&.first

      author.name = fix_studio(fix_misc(fix_quality(author.name)))
      change_videos_quality author, quality if quality

      if author.changes.any?
        transfer_videos author unless author.save
      end
    end
  end

  def authors
    @authors ||= AnimeVideoAuthor.order(:id).to_a
  end

  def match_quality name
    QUALITIES_REPLACEMENTS.find do |_, regexp|
      name =~ regexp
    end
  end

  def fix_quality name
    QUALITIES_REPLACEMENTS.inject(name) do |memo, (_, regexp)|
      memo.gsub(regexp, '').strip
    end
  end

  # rubocop:disable MethodLength
  def fix_misc name
    name
      .gsub(/\[+/, '(')
      .gsub(/\]+/, ')')
      .gsub(/\(\(+/, '(')
      .gsub(/\)\)+/, ')')
      .gsub(/\A\( (.*) \)\Z/mix, '\1')
      .gsub(', ', ' & ')
      .gsub(' и ', ' & ')
      .gsub(/\A[^ivx\d] /i, '')
      .gsub(/ &[)($]/, '')
      .gsub('  ', ' ')
      .gsub(/ [)\]]|[(\[] /, '\1')
  end
  # rubocop:enable MethodLength

  def fix_studio name
    fixed_name = STUDIOS_REPLACEMENTS
      .inject(name) do |memo, (regexp, replacement)|
        memo.gsub(regexp, replacement).strip
      end

    STUDIOS_REPOSITIONS
      .inject(fixed_name) do |memo, (regexp, replacement)|
        memo.gsub(regexp, replacement).strip
      end
  end

  def change_videos_quality author, quality
    log 'quality', author, quality
    author.anime_videos.update_all quality: quality
  end

  def transfer_videos author
    log 'transfer', author
    new_author = original_author author

    author.anime_videos.update_all(
      anime_video_author_id: new_author ? new_author.id : nil
    )
  end

  def log action, author, info = nil
    names = '`' + (author.changes[:name] || [author.name]).join('` -> `') + '`'
    counts = pluralize author.anime_videos.count, 'videos'
    text = [action, names, info, counts].compact.join(' ')

    NamedLogger.fix_anime_video_authors.info text
  end

  def original_author author
    AnimeVideoAuthor.find_by name: author.changes[:name].second
  end
end
# rubocop:enable ClassLength
