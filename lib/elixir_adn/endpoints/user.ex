defmodule ElixirADN.Endpoints.User do
  alias ElixirADN.Endpoints.Http
  alias ElixirADN.Endpoints.Parameters.Encoder
  alias ElixirADN.Endpoints.Parameters.Pagination
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.UserParameters
  alias ElixirADN.Parser.ResultParser

  @moduledoc ~S"""
  An interface to the user endpoints in ADN.  They are urls begining with 
  /users here:
  
  https://developers.app.net/reference/resources/ 
  """ 

  @doc ~S"""
  Returns the user for a given username or user id taking into account 
  the parameter objects passed in.  The user id can be the @username format or the numerical id
  """
  def get(user_id, %UserParameters{} = user_parameters) when is_binary(user_id) or is_integer(user_id) do
    {:ok, query_string} = Encoder.generate_query_string([user_parameters])
    Http.call({:get, "https://api.app.net/users/#{user_id}#{query_string}"})
      |> ResultParser.convert_to(ElixirADN.Model.User)
  end

  @doc ~S"""
  Returns the posts for a given user taking into account the parameter objects
  passed in.  The user id can be the @username format or the numerical id
  """
  def get_posts(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination) when is_binary(user_id) or is_integer(user_id) do
    {:ok, query_string} = Encoder.generate_query_string([post_parameters, pagination])
    Http.call({:get, "https://api.app.net/users/#{user_id}/posts#{query_string}"})
      |> ResultParser.convert_to(ElixirADN.Model.Post)
  end

  @doc ~S"""
  Returns the posts mentioning a given user taking into account the parameter objects
  passed in.  A token (app or user) is required and the user_id can be either the 
  @username format or a numerical id
  """
  def get_mentions(user_id, %PostParameters{} = post_parameters, %Pagination{} = pagination, token) when is_binary(user_id) or is_integer(user_id) do
    {:ok, query_string} = Encoder.generate_query_string([post_parameters, pagination])
    Http.call({:get, "https://api.app.net/users/#{user_id}/mentions#{query_string}"}, token)
      |> ResultParser.convert_to(ElixirADN.Model.Post)
  end
  
end