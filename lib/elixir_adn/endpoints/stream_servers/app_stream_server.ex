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
  	body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(stream_parameters)
  	%HTTPoison.Response{ body: body } = HTTPoison.post!("https://api.app.net/streams", body, [{"Authorization", "Bearer #{app_token}"}, {"Content-Type","application/json"}])
  	{:ok, %{"endpoint" => endpoint, "id" => stream_id} } = ResultParser.parse(:stream, body)
  	HTTPoison.get(endpoint, [{"Authorization", "Bearer #{app_token}"}], timeout: :infinity, stream_to: self())
  	{:reply, :ok, %{app_token: app_token, stream_id: stream_id}}
  end

  @doc """
  Wait for the stream to return an item.  If it's valid,
  return it, otherwise recurse until we get a valid item
  """
  def handle_call({:get_next_item}, from, state) do
    receive do
    	#If it's a header (it shouldn't be) just continue waiting
    	%HTTPoison.AsyncHeaders{} ->
				handle_call({:get_next_item}, from, state)
			#if it's status, just keep waiting
			%HTTPoison.AsyncStatus{} ->
				handle_call({:get_next_item}, from, state)
			#If it's an empty chunk, continue waiting
			%HTTPoison.AsyncChunk{chunk: ""} ->
				#Call it again
				handle_call({:get_next_item}, from, state)
			#If it's a valid chunk, process it and if it's
			#an item we care about add it to the stream or
			#continue waiting
			%HTTPoison.AsyncChunk{chunk: chunk} ->
				item = get_all_chunks(chunk)
					|> process_chunk()
				case item do
					nil -> handle_call({:get_next_item}, from, state)
					#data isn't an array, so make it one to match the rest of 
					#the endpoints
					_ -> {:reply, {[item], self}, state}
				end
				
			#End of the stream, but shouldn't happen with ADN streams
			%HTTPoison.AsyncEnd{} ->
				IO.puts "end"
				{:reply, {:halt, self}, state }
			#Something else (included for debugging)
			var ->
				IO.puts "unknown value"
				IO.inspect var
				{:reply, {:halt, self}, state }
		end
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

  defp get_all_chunks(acc) do
  	case String.ends_with?(acc, "\r\n") do
			true -> 
				acc
			false ->
				receive do
					%HTTPoison.AsyncChunk{chunk: chunk} -> get_all_chunks(acc <> chunk)
					%HTTPoison.AsyncEnd{} -> IO.puts "End?!"
				end
		end
  end
  
  #\r\n is the item seperator so return nil so it gets skipped
  defp process_chunk("\r\n") do
  	nil
  end

  #Decode an item from the stream
  defp process_chunk(chunk_json) do
  	{:ok, map } = ResultParser.parse(:stream, chunk_json)
  	ResultParser.decode("token", map, :stream)
  end
end