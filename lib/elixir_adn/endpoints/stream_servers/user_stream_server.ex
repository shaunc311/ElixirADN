defmodule ElixirADN.Endpoints.StreamServers.UserStreamServer do
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

  Returns `{:ok, connection_id}` if the stream creates successfully, 
  otherwise it returns the error from the endpoint
  """
  def start_streaming(server, user_token, stream_parameters) do
    GenServer.call(server, {:setup_stream, user_token, stream_parameters}, :infinity)
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
  def handle_call({:setup_stream, user_token, stream_parameters}, _from, _state) do
  	#Store the user token until we close the stream
  	query_parameters = case ElixirADN.Endpoints.Parameters.Encoder.generate_query_string([stream_parameters]) do
  		{:ok, "" } -> "?autodelete=1"
  		{:ok, x } -> "#{x}&autodelete=1"
  	end
  	HTTPoison.get("https://stream-channel.app.net/stream/user#{query_parameters}", [{"Authorization", "Bearer #{user_token}"}], timeout: :infinity, stream_to: self())
		#Wait for the connection id header to come in
		connection_id_result = stream_for_connection_id()
		case connection_id_result do
			{:ok, connection_id} ->  
				{:reply, {:ok, connection_id}, %{connection_id: connection_id, user_token: user_token}}
			error -> 
				{:reply, error, %{user_token: user_token}}
		end
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
			#If it's an empty chunk, continue waiting
			%HTTPoison.AsyncChunk{chunk: ""} ->
				#Call it again
				handle_call({:get_next_item}, from, state)
			#If it's a valid chunk, process it and if it's
			#an item we care about add it to the stream or
			#continue waiting
			%HTTPoison.AsyncChunk{chunk: chunk} ->
				items = get_all_chunks(chunk)
					|> process_chunk()
				case items do
					nil -> handle_call({:get_next_item}, from, state)
					_ -> {:reply, {items, self}, state}
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

  def handle_call({:close}, _from, %{connection_id: connection_id, user_token: user_token} = state) when is_binary(connection_id) do
  	#This returns no_content when it succeeds
  	result = Http.call({:delete, "https://api.app.net/users/me/streams/#{connection_id}"}, [{"Authorization", "Bearer #{user_token}"}])
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

  #Wait for the connection id
	defp stream_for_connection_id() do
  	receive do
  		#Stream was created correctly which is good
  		#but it's not the connection id so keep waiting
  		%HTTPoison.AsyncStatus{code: 200} -> 
				stream_for_connection_id

			#A user can only have 5 streams so if it's
			#exceeded, we need to return the error
			%HTTPoison.AsyncStatus{code: 400} -> 
				IO.puts "too many streams"
				{:error, :too_many_streams}

			#Any other status code is just as bad so return
			#that too
			%HTTPoison.AsyncStatus{code: code} -> 
				IO.puts "bad status code"
				IO.inspect code
				{:error, {:bad_status_code, code}}
			#Get the connection ID from the header
			%HTTPoison.AsyncHeaders{} = headers -> 
				get_connection_id(headers)
			
			#The connection got lost somehow
			%HTTPoison.AsyncEnd{} -> 
				{:error, :connection_closed}

			#Some other message came back, just here
			#for debugging
			x ->
				IO.puts "Unexpected value"
				IO.inspect x
				stream_for_connection_id
		end
  end

  #Pull the connection id from the header
	defp get_connection_id(%HTTPoison.AsyncHeaders{headers: headers}) do
		connection_id = Map.get(headers, "Connection-Id")
		{:ok, connection_id}
	end
end