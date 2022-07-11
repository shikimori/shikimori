class MigrateBirthdayVersions < ActiveRecord::Migration[6.1]
  def up
    Version
      .where('(item_diff->>:field) is not null', field: :birthday)
      .each do |version|
        version.update! item_diff: { 'birth_on' => version.item_diff['birthday'] }
      end
  end

  def down
    Version
      .where('(item_diff->>:field) is not null', field: :birth_on)
      .each do |version|
        version.update! item_diff: { 'birthday' => version.item_diff['birth_on'] }
      end
  end
end
