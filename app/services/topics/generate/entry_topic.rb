# frozen_string_literal: true

class Topics::Generate::EntryTopic < Topics::Generate::Topic
  private

  # no updated_at to prevent display of empty topics on the forum
  def updated_at
    nil
  end
end
