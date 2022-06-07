class TestsController < Simpler::Controller

  def index
    @time = Time.now

    render plain: "It's a plain text response", status: 201
  end

  def create
  end

  def show
    @id = params['id']
  end
end
