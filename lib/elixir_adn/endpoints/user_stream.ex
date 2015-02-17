defmodule ElixirADN.Endpoints.UserStream do
	alias ElixirADN.Endpoints.Parameters.StreamEndpointParameters
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Subscription
	alias ElixirADN.Endpoints.StreamServers.UserStreamServer

	@moduledoc  ~S"""
	User Streams are a way to stream endpoints from ADN.  Full documentation
	can be found here:

	https://developers.app.net/reference/resources/user-stream/

	Here are the current subscriptions a stream can connect with:

	* /users/me/following
	* /users/me/followers
	* /users/me/posts
	* /users/me/mentions
	* /posts/:post_id/replies
	* /posts/tag/:hashtag
	* /posts/stream
	* /posts/stream/unified
	* /channels (includes new messages for channels you’re subscribed to)
	* /channels/:channel_id/subscribers
	* /channels/:channel_id/messages
	* /users/me/files
	* /token (includes updates for both the token and the user objects of the current user)
	
	Here are the limits for a user stream:

	* Each User Stream expires approximately 5 minutes after the connection is closed
	* Each user token can create at most 5 User Streams
	* Each User Stream can have at most 50 subscriptions. The same endpoint can be subscribed to multiple times.
	
	"""

	@doc ~S"""
	Streams ADN endpoints.  Based on the post by Benjamin Tam:
	http://benjamintan.io/blog/2015/02/05/how-to-build-streams-in-elixir-easily-with-stream-resource-awesomeness/
	"""
	def stream(user_token, %StreamEndpointParameters{} = stream_parameters, subscription_urls) do
		Stream.resource( 
			#The initial state function
			fn -> create_stream(user_token, stream_parameters, subscription_urls) end,
			#The "next" function
			fn(x) -> stream_for_result(x) end,
			#The close function
			fn(x) -> close_stream(x) end
		)
		
	end

	#Stream.resource function to create the stream
	defp create_stream(_user_token, _stream_parameters, []), do: {:halt, :error}
	defp create_stream(user_token, stream_parameters, subscriptions) when is_list(subscriptions) do
		#create a stream and get the connection id (assuming the stream creates correctly, otherwise crash)
		{:ok, pid} = UserStreamServer.start_link()
		{:ok, connection_id} = UserStreamServer.start_streaming(pid, user_token, stream_parameters)
		#Add each subscription
		#TODO: verify it works ok since the 50 subscription max can hit
		Enum.each(subscriptions, fn(x) -> subscribe_to_endpoint(x, connection_id, user_token) end)
		#Return the PID so the other stream functions can access the server
		pid
	end

	#Subscribe to each endpoints
	#TODO: do this outside the stream so subscriptions can be added
	#after the creation.  So if the user adds a channel they can subscribe
	#to it's messages while streaming.
	defp subscribe_to_endpoint(endpoint, connection_id, user_token) do
		{:ok, url} = Subscription.subscribe(endpoint, connection_id)
		Http.call({:get, url}, ["Authorization": "Bearer #{user_token}"])
	end

	#Delete the stream
	defp close_stream(_process_id) do
		#currently they are created to auto-delete but this should 
		#delete it
	end

	#Get the next item in the stream
	defp stream_for_result(pid) do
		UserStreamServer.get_next_item(pid)
	end
end