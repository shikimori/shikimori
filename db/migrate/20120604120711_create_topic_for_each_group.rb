
class CreateTopicForEachGroup < ActiveRecord::Migration
  def self.up
    Entry.record_timestamps = false
    Comment.record_timestamps = false
    GroupComment.record_timestamps = false

    # section for groups
    section = Section.find_or_create_by_permalink(permalink: 'g', description: 'Топики групп.', meta_description: "Форум групп сайта.", meta_keywords: 'Группы', meta_title: 'Группы', name: 'Группы', position: 9)

    Group.all.each do |group|
      # fix owner
      group.update_attribute(:owner_id, group.admins.first.id)
      # create topic
      topic = GroupComment.create!(linked: group, created_at: group.created_at, updated_at: group.updated_at, forum: section, user: group.owner)
      # subscribe members to topic
      group.members.each do |user|
        user.subscribe(topic)
      end
      # move all comments to topic
      Comment.where(commentable: group).update_all(commentable_id: topic.id, commentable_type: Entry.name)
      # topic updated_at to last comment's created_at
      topic.update_attributes(updated_at: topic.comments(nil).first.created_at) if topic.comments(nil).first
    end

    GroupComment.record_timestamps = true
    Comment.record_timestamps = true
    Entry.record_timestamps = true
  end

  def self.down
    raise 'irreversible migration'
  end
end
