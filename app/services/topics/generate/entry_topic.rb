# frozen_string_literal: true

class Topics::Generate::EntryTopic < Topics::Generate::Topic
private

  # nil - to prevent display on forum
  def updated_at
    nil
  end
end
