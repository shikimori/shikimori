class AnimesVerifier
  include Sidekiq::Worker
  extend DslAttribute

  sidekiq_options(
    dead: false,
    retry: false
  )

  sidekiq_retry_in { 60 * 60 * 24 }

  dsl_attribute :klass, Anime
  dsl_attribute :ignore_ids, []

  BAD_MAL_DESCRIPTIONS = [
    '%meta property%',
    '%<script%',
    '%<span%',
    '%<div%',
    '%scrip>t%',
    '%span>%',
    '%div>%',
    '%<center>%',
    '%<b>%',
    '%<i>%',
    '%<strong>%',
    '%<img%',
    '%<a %',
    '%"http://%'
  ]
  BAD_DESCRIPTIONS = BAD_MAL_DESCRIPTIONS + [
    '%adultmanga%',
    '%doramatv%',
    '%readmanga%',
    '%findanime%',
    '%ru',
    '%com',
    '%org',
    '%info',
    '%www.%',
    '%ucoz%',
    '%Удалено по просьбе%',
    '%Редактировать описание',
    '%Описание представлено'
  ]

  def perform
    if bad_entries.any?
      bad_entries.each do |id|
        MalParsers::FetchEntry.new.perform id, klass.name.downcase
      end
    end

    if bad_entries.any?
      raise "#{bad_entries.size} broken entries found: #{bad_entries.join ', '}"
    end

    if bad_mal_descriptions.any?
      raise "#{bad_mal_descriptions.size} broken mal_descriptions found: \
#{bad_mal_descriptions.join ', '}"
    end

    if bad_images.any?
      raise "#{bad_images.size} bad #{klass.name} images found: #{bad_images.join ', '}"
    end
  end

private

  def bad_entries
    klass.where(name: nil).pluck(:id)
  end

  def bad_descriptions
    @bad_descriptions ||= klass
      .where(
        BAD_DESCRIPTIONS
          .map { |v| "description_ru ilike '#{v}'" }
          .join(' or ')
      )
      .where.not(id: ignore_ids)
      .where.not(id: ChangedItemsQuery.new(klass).fetch_ids)
      .pluck(:id)
  end

  def bad_mal_descriptions
    @bad_mal_descriptions ||= klass
      .where(
        BAD_MAL_DESCRIPTIONS
          .map { |v| "description_en ilike '#{v}'" }
          .join(' or ')
      )
      .where.not(id: ignore_ids)
      .pluck(:id)
  end

  def bad_images
    @bad_images ||= klass.all
      .select do |entry|
        next unless entry.image.exists?
        Paperclip::Geometry.from_file(entry.image.path).width.to_i < 50
      end
      .each { |entry| ImageReloader.call entry }
      .select do |entry|
        Paperclip::Geometry.from_file(entry.image.path).width.to_i < 50
      end
      .map(&:id)
  end
end
