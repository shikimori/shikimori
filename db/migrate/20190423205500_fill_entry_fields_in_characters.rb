class FillEntryFieldsInCharacters < ActiveRecord::Migration[5.2]
  def up
    Characters::JobsWorker.new.perform
  end
end
