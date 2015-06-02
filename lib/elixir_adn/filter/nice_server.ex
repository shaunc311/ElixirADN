defmodule ElixirADN.Filter.NiceServer do
  alias ElixirADN.Filter.NiceUpdateServer
  alias ElixirADN.Parser.ResultParser
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
  def get_rank(server, user_id) do
    GenServer.call(server, {:get_rank, user_id}, :infinity)
  end

  @doc """
  Is this account human?

  Returns `{:ok, true/false}` 
  """
  def is_human?(server, type, user_id) do
    GenServer.call(server, {:is_human, type, user_id},  :infinity)
  end

  @doc """
  Add a user's nicerank to the map

  Returns `{:ok}` 
  """
  def update_user(server, user_id, user_value) do
    GenServer.call(server, {:update_user, user_id, user_value},  :infinity)
  end

  @doc """
  Begin the update process by marking each item as not updated

  Returns `{:ok}` 
  """
  def mark_updating(server) do
    GenServer.call(server, {:begin_update},  :infinity)
  end

  @doc """
  Begin the update process by marking each item as not updated

  Returns `{:ok}` 
  """
  def finish_updating(server) do
    GenServer.call(server, {:finish_update},  :infinity)
  end


  ## Server API
  @doc """
  Init with an empty hashdict
  """
  def init(:ok) do
    #Make the call to nice to get the user rankings
    {:ok, HashDict.new}
  end

  @doc """
  Get the rank for a user and check to see if the rankings need to be
  updated
  """
  def handle_call({:get_rank, user_id}, _from, state) do
    value = case HashDict.fetch(state, user_id) do
      {:ok, user_value} -> {:ok, Map.get(user_value, "rank")}
      #Error means it wasn't in the cache yet
      :error -> 
        case get_user_from_nice(user_id) do
          nil -> {:error, :no_user}
          user -> 
            state = HashDict.put(state, user_id, user)
            {:ok, Map.get(user, "rank") }
        end
    end
    {:reply, value, state}
  end

  @doc """
  Get the rank for a user and check to see if the rankings need to be
  updated
  """
  def handle_call({:is_human, "human", user_id}, _from, state) do
    value = case HashDict.fetch(state, user_id) do
      {:ok, user_value} -> 
        {:ok, Map.get(user_value, "is_human") == "Y"}
      :error -> 
        case get_user_from_nice(user_id) do
          nil -> {:error, :no_user}
          user -> 
            state = HashDict.put(state, user_id, user)
            {:ok, Map.get(user, "is_human") == Y }
        end
    end
    {:reply, value, state}
  end

  #if it's not a human, skip it
  def handle_call({:is_human, _, _user_id}, _from, state) do
    {:reply, {:ok, false}, state}
  end

  @doc """
  Update the values associted with a user
  """
  def handle_call({:update_user, user_id, user_value}, _from, state) do
    {:reply, :ok, HashDict.put(state, Integer.to_string(user_id), user_value)}
  end

  @doc """
  Begin updating the user state
  """
  def handle_call({:begin_update}, _from, state) do
    case HashDict.size(state) do
      0 -> state
      _ -> 
        #default each user to not updated
        state = Enum.reduce(state, HashDict.new, fn({key,value}, acc) -> acc = HashDict.put(acc, key, Map.put(value,"updated", false)) end)
    end
    {:reply, :ok, state}
  end

  @doc """
  Finish updating
  """
  def handle_call({:finish_update}, _from, state) do
    state = case HashDict.size(state) do
      0 -> state
      _ -> 
        #Only add user that were just updated
        Enum.reduce(state, HashDict.new, fn({key,value}, acc) -> 
          acc = case Map.get(value, "updated") do
            true -> HashDict.put(acc, key, value)
            false -> acc
          end
        end )
    end
    {:reply, :ok, state}
  end

  defp get_user_from_nice(user_id) do
    {:ok, ranking_array} = HTTPoison.get!("http://api.nice.social/user/nicerank?ids=#{user_id}", timeout: :infinity)
      |> ResultParser.convert_to(:map)
    
    first_result = ranking_array 
      #default this to false
      |> Enum.map(fn(x) -> Map.put(x,"updated", false) end)
      |> List.first
  end

end