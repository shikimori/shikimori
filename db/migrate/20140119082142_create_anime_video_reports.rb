class CreateAnimeVideoReports < ActiveRecord::Migration
  def change
    create_table :anime_video_reports do |t|
      t.references :anime_video
      t.references :user
      t.integer :approver_id
      t.string :kind
      t.string :state
      t.string :user_agent

      t.timestamps
    end

    add_index :anime_video_reports, [:anime_video_id, :kind, :state]#, unique: true
  end
end
