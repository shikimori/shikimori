class AnimesVerifier
  include Sidekiq::Worker
  extend DslAttribute

  sidekiq_options(
    unique: :until_executed,
    dead: false,
    unique_job_expiration: 60 * 60 * 24 * 30
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
  IGNORE_IDS = []

  def perform
    klass.import bad_entries if bad_entries.any?

    raise "Broken entries found: #{bad_entries.join ', '}" if bad_entries.any?

    if bad_mal_descriptions.any?
      raise "Broken mal_descriptions found: #{bad_mal_descriptions.join ', '}"
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
          .map { |v| "description ilike '#{v}'" }
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
          .map { |v| "description_mal ilike '#{v}'" }
          .join(' or ')
      )
      .pluck(:id)
  end

  def klass_parser
    "#{klass.name}MalParser".constantize
  end
end
