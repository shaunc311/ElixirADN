defmodule ElixirADN.Endpoints.Post do
  alias ElixirADN.Endpoints.Http
  alias ElixirADN.Endpoints.Parameters.Encoder
  alias ElixirADN.Endpoints.Parameters.Pagination
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Model.Post
  alias ElixirADN.Parser.ResultParser

  @moduledoc ~S"""
  An interface to the posts endpoints in ADN.  They are urls begining with 
  /posts here:
  
  https://developers.app.net/reference/resources/ 
  """ 
  @doc ~S"""
  Post to ADN.  This requests a user token.
  """
  def create_post(%Post{} = post, user_token) when is_binary(user_token) do
    Encoder.generate_json(post)
      |> Http.call({:post, "https://api.app.net/posts"}, user_token)
  end

  @doc ~S"""
  Get posts from the global stream
  """
  def get_posts(%PostParameters{} = post_parameters, %Pagination{} = pagination) do
    {:ok, query_string} = Encoder.generate_query_string([post_parameters, pagination])
    Http.call({:get, "https://api.app.net/posts/stream/global#{query_string}"})
      |> ResultParser.convert_to(ElixirADN.Model.Post)
  end
end