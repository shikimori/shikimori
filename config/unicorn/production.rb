# Should be 'production' by default, otherwise use other env 
rails_env = 'production'

# Set your full path to application.
app_name = 'shikimori'
app_root = "/home/apps/#{app_name}/#{rails_env}"
app_path = "#{app_root}/current"
shared_path = "#{app_root}/shared"

# Set unicorn options
worker_processes 30
timeout 90
listen "#{shared_path}/tmp/sockets/unicorn.socket", backlog: 4098

# Spawn unicorn master worker for user apps (group: apps)
user 'devops'

# Fill path to your app
working_directory app_path

# Log everything to one file
stderr_path "#{shared_path}/log/unicorn.error.log"
# stdout_path "#{shared_path}/log/unicorn.log"

# Set master PID location
pid "#{shared_path}/tmp/pids/unicorn.pid"

preload_app true

# combine Ruby 2.0.0dev or REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# whilE queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_path}/Gemfile"
end

before_fork do |server, worker|
  #Signal.trap 'TERM' do
    #puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    #Process.kill 'QUIT', Process.pid
  #end

  defined?(ApplicationRecord) and
    ApplicationRecord.connection.disconnect!

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      #Process.kill("QUIT", File.read(old_pid).to_i)
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  #
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  # sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, tries: -1, delay: 5, tcp_nopush: true)

  # the following is *required* for Rails + "preload_app true",
  ApplicationRecord.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
