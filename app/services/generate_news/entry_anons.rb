class GenerateNews::EntryAnons < ServiceObjectBase
  pattr_initialize :entry

  def call
    find_news || fix_timestamps(create_news)
  end

  def is_processed
    false
  end

  def action
    AnimeHistoryAction::Anons
  end

  def value
  end

  def created_at
    Time.zone.now
  end

private

  def find_news
    Topics::NewsTopic.find_by options
  end

  def create_news
    Topics::NewsTopic.create options.merge(
      forum_id: forum_id,
      updated_at: nil,
      generated: true,
      processed: is_processed
    )
  end


  def forum_id
    entry_name = @entry.class.name || fail(ArgumentError, @entry.class.name)
    DbEntryThread::FORUM_IDS[entry_name]
  end

  def options
    {
      linked_id: @entry.id,
      linked_type: @entry.class.name,
      action: action,
      value: value
    }
  end

  # disabling record_timestamps in ActiveRecors is ugly and not thread safe!
  def fix_timestamps topic
    topic.update_columns(
      created_at: created_at,
      updated_at: nil
    )
    topic
  end
end
