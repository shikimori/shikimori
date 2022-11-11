class MigrateOldPosterVersions < ActiveRecord::Migration[6.1]
  def up
    Version
      .where(type: 'Versions::PosterVersion')
      .update_all(type: 'Versions::PosterOldVersion')
  end

  def down
    if Version.where(type: 'Versions::PosterVersion').any?
      raise ActiveRecord::IrreversibleMigration
    end

    Version
      .where(type: 'Versions::PosterOldVersion')
      .update_all(type: 'Versions::PosterVersion')
  end
end
