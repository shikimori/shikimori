class FixDescriptionVersions < ActiveRecord::Migration
  def up
    Versions::DescriptionVersion.find_each do |version|
      version.fix_state
    end
  end
end
