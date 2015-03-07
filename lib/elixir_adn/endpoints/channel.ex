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
		Encoder.generate_json(message)
			|> Http.call({:post, "https://api.app.net/channels/#{message.channel_id}/messages"}, user_token)	
	end
end