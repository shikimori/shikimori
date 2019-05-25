# TODO: remove after timeout test finish (27-10-2015)
class LogBeforeTimeout
  UNICORN_TIMEOUT = 55

  def initialize app
    @app = app
  end

  def call env
    thread = thread_logger env
    @app.call env

  ensure
    thread[:done] = true
  end

private

  def thread_logger env
    Thread.new do
      sleep UNICORN_TIMEOUT - 2 # set this to Unicorn timeout - 1

      unless Thread.current[:done]
        qs = env['QUERY_STRING']
        path = "#{env['PATH_INFO']}?#{qs}"
        NamedLogger.slow_requests.info path
      end
    end
  end
end
