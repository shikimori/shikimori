BLACKLIST = %w[
  .git
  log
  node_modules
  public
  tmp
]

module SpringWatcherListenIgnorer
  def start
    super
    listener.ignore Regexp.new(BLACKLIST.map { |v| "^#{v}" }.join('|'))
  end
end
Spring::Watcher::Listen.prepend SpringWatcherListenIgnorer

Spring.watch(
  '.ruby-version',
  '.rbenv-vars',
  'tmp/restart.txt',
  'tmp/caching-dev.txt'
)
