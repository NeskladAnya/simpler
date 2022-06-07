require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    request_info(env)
    response_info(env, status, headers)

    [status, headers, body]
  end

  private
  def request_info(env)
    @request = Rack::Request.new(env)

    controller = env['simpler.controller']
    action = env['simpler.action']

    log = "Request: #{env['REQUEST_METHOD']} #{env['REQUEST_URI']}\n"
    log += "Handler: #{controller.name}##{action}\n"
    log += "Parameters: #{@request.params}"

    @logger.info(log)
  end

  def response_info(env, status, headers)
    log = "Response: #{status} [#{headers['Content-Type']}] "

    log += (env['simpler.file_path']).to_s

    @logger.info(log)
  end
end
