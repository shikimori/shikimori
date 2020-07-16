class DestroyCopyrightedTopic < ActiveRecord::Migration[5.2]
  def change
    Topic.find_by(id: 247_567)&.destroy
  end
end
