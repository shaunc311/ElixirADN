defmodule ElixirADN.Helpers.ResponseHelper do
	@moduledoc ~S"""
	A  module to help make responding to posts and messages seemless so 
	it's easier to pipe responses
	"""

	@doc ~S"""
	A helper to respond to a post
	"""
	def respond(user_token, %ElixirADN.Model.Response{} = response, %ElixirADN.Model.Post{} = original_post) do
		post = %ElixirADN.Model.Post{ entities: response.entities, machine_only: response.machine_only, reply_to: original_post.id, text: response.text, annotations: response.annotations}
		ElixirADN.Endpoints.Post.create_post(user_token, post)
	end

	@doc ~S"""
	A helper to respond to a message in a channel
	"""
	def respond(user_token, %ElixirADN.Model.Response{} = response, %ElixirADN.Model.Message{} = original_message) do
		message = %ElixirADN.Model.Message{ channel_id: original_message.channel_id, entities: response.entities, machine_only: response.machine_only, reply_to: original_message.id, text: response.text, annotations: response.annotations}
		ElixirADN.Endpoints.Channel.create_message(user_token, message)
	end	
end