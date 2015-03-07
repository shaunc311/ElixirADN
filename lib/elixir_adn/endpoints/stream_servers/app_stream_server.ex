defmodule ElixirADN.Endpoints.StreamServers.AppStreamServer do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Parser.ResultParser
	use GenServer

  ## Client API

  @doc """
  Starts the stream server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Start the stream with an infinite timeout

  Returns `:ok` if the stream creates successfully, 
  otherwise it returns the error from the endpoint
  """
  def start_streaming(server, app_token, stream_parameters) do
    GenServer.call(server, {:setup_stream, app_token, stream_parameters}, :infinity)
  end

  @doc """
  Gets the next item in the stream and will wait indefinitely for it
  """
  def get_next_item(server) do
    GenServer.call(server, {:get_next_item}, :infinity)
  end

  def close_stream(server) do
  	GenServer.call(server, {:close}, :infinity)
  end

  ## Server Callbacks

  @doc """
  There is no initial state
  """
  def init(:ok) do
    {:ok, %{}}
  end

  @doc """
  Call the ADN endpoint to create the stream.  It's asynchonous so it 
  will stay open after the call returns
  """
  def handle_call({:setup_stream, app_token, stream_parameters}, _from, _state) do
  	#we need to create the stream to get the url
  	%{"endpoint" => endpoint, "id" => stream_id} = ElixirADN.Endpoints.Parameters.Encoder.generate_json(stream_parameters)
      |> Http.call({:post, "https://api.app.net/streams"}, app_token)
      |> ResultParser.convert_to(:map)
  	HTTPoison.get(endpoint, [{"Authorization", "Bearer #{app_token}"}], timeout: :infinity, stream_to: self())
  	{:reply, :ok, %{app_token: app_token, stream_id: stream_id}}
  end

  @doc """
  Wait for the stream to return an item.  If it's valid,
  return it, otherwise recurse until we get a valid item
  """
  def handle_call({:get_next_item}, from, state) do
    items = ElixirADN.Endpoints.StreamServers.Receiver.receive_message()
    {:reply, {items, self}, state}
  end

  def handle_call({:close}, _from, %{app_token: app_token, stream_id: stream_id} = state) do
  	#This returns no_content when it succeeds
  	result = Http.call({:delete, "https://api.app.net/streams/#{stream_id}"}, [{"Authorization", "Bearer #{app_token}"}])
  	case result do
  		{:error, :no_content} -> {:reply, {:ok}, %{}}
  		_ -> {:reply, {:halt, self}, state }
  	end
  end

  def handle_call({:close}, _from, _state) do
  	#Stream  wasn't created so don't worry about closing it
  	{:reply, {:ok}, %{}}
  end
end