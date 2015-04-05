defmodule ElixirADN.Filter.NiceServer do
  alias ElixirADN.Filter.NiceUpdateServer
  use GenServer

  ## Client API

  @doc """
  Starts the nice server.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Get the nice rank for a user

  Returns `{:ok, rank}` if the username exists or 
  {:ok, :no_user} if no user is found
  """
  def get_rank(server, username) do
    GenServer.call(server, {:get_rank, username})
  end

  @doc """
  Is this account human?

  Returns `{:ok, true/false}` 
  """
  def is_human?(server, username) do
    GenServer.call(server, {:is_human, username})
  end

  @doc """
  Add a user's nicerank to the map

  Returns `{:ok}` 
  """
  def update_user(server, username, user_value) do
    GenServer.call(server, {:update_user, username, user_value})
  end


  ## Server API
  @doc """
  Init with an empty hashdict
  """
  def init(:ok) do
    #Make the call to nice to get the user rankings
    #spawn(fn -> update_rankings end)
    {:ok, HashDict.new}
  end

  @doc """
  Get the rank for a user and check to see if the rankings need to be
  updated
  """
  def handle_call({:get_rank, username}, _from, state) do
    value = case HashDict.fetch(state, username) do
      {:ok, user_value} -> {:ok, Map.get(user_value, "rank")}
      :error -> {:ok, :no_user}
    end
    {:reply, value, state}
  end

  @doc """
  Get the rank for a user and check to see if the rankings need to be
  updated
  """
  def handle_call({:is_human, username}, _from, state) do
    value = case HashDict.fetch(state, username) do
      {:ok, user_value} -> {:ok, Map.get(user_value, "is_human") == "Y"}
      :error -> {:ok, :no_user}
    end
    {:reply, value, state}
  end

  @doc """
  Update the values associted with a user
  """
  def handle_call({:update_user, username, user_value}, _from, state) do
    {:reply, :ok, HashDict.put(state, username, user_value)}
  end

end