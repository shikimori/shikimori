const PUBLIC_FIELDS = [
  'id',
  'url',
  'is_moderator',
  'is_day_registered',
  'is_week_registered',
  'is_comments_auto_collapsed',
  'is_comments_auto_loaded'
];

export default class ShikiUser {
  constructor(data) {
    this.data = data;
    this.isSignedIn = !!this.data.id;

    PUBLIC_FIELDS.forEach(field => this[field.camelize(false)] = this.data[field]);
  }

  isTopicIgnored(topicId) {
    return this.data.ignored_topics.indexOf(topicId) !== -1;
  }

  isUserIgnored(userId) {
    return this.data.ignored_users.indexOf(userId) !== -1;
  }

  ignoreTopic(topicId) {
    return this.data.ignored_topics.push(parseInt(topicId));
  }

  unignoreTopic(topicId) {
    return this.data.ignored_topics.remove(parseInt(topicId));
  }
}
