defmodule ElixirADN.Endpoints.Channel do
	alias ElixirADN.Endpoints.Http
	alias ElixirADN.Endpoints.Parameters.Encoder
	alias ElixirADN.Model.Message

	@moduledoc ~S"""
	An interface to the channels endpoints in ADN.  They are urls begining with 
	/channels here:
	
	https://developers.app.net/reference/resources/	
	"""	
	@doc ~S"""
	Add a message to an ADN channel.  This requests a user token.
	"""
	def create_message(user_token, %Message{} = message) when is_binary(user_token) do
		process_add_message(user_token, message)
	end

	def create_message(_,_) do
		{:error, :invalid_object_to_message}
	end

	#Call the post endpoint with the json post
	defp process_add_message(token, %Message{} = message ) do
		body = Encoder.generate_json(message)
		Http.call({:post, "https://api.app.net/channels/#{message.channel_id}/messages"}, body, [{"Authorization","Bearer #{token}"}, {"Content-Type", "application/json"}])	
	end
end