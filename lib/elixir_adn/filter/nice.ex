defmodule ElixirADN.Filter.Nice do
  alias ElixirADN.Filter.NiceServer

  @moduledoc ~S"""
  A NiceRank filter based on the @matigo's nicerank algorith.  Start the
  NiceRank server and NiceRank update server in your application config
  if you want to use this.
  """

  @doc ~S"""
  Filter posts by the default 2.1 ranking
  """
  def filter_default(%ElixirADN.Model.Post{} = post, server) do
    filter_by_rank(post, 2.1, server)
  end

  @doc ~S"""
  Filter posts by a user defined ranking
  """
  def filter_by_rank(%ElixirADN.Model.Post{} = post, rank, server) when is_number(rank) do
    case NiceServer.get_rank(server, post.user.id) do
      #new users get the benefit of the doubt
      {:ok, :no_user} -> true
      #make sure the rank is OK
      {:ok, user_rank} -> user_rank >= rank
    end
  end

  @doc ~S"""
  Filter human users by the default rank
  """
  def filter_human_default(%ElixirADN.Model.Post{} = post, server) do
    case NiceServer.is_human?(server, post.user.type, post.user.id) do
      {:ok, :no_user} -> true
      {:ok, true } -> filter_default(post, server)
      {:ok, false } -> false
    end
  end

  @doc ~S"""
  Filter human users by the given rank
  """
  def filter_human_by_rank(%ElixirADN.Model.Post{} = post, rank, server) do
    case NiceServer.is_human?(server, post.user.type, post.user.id) do
      {:ok, :no_user} -> true
      {:ok, true } -> filter_by_rank(post, rank, server)
      {:ok, false } -> false
    end
  end
end