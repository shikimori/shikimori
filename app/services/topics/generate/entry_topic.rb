# frozen_string_literal: true

class Topics::Generate::EntryTopic < Topics::Generate::Topic
private

  # nil - чтобы не отображалось на форуме
  def updated_at
    nil
  end
end
