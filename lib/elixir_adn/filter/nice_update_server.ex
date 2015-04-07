defmodule ElixirADN.Filter.NiceUpdateServer do
  alias ElixirADN.Filter.NiceServer
  alias ElixirADN.Parser.ResultParser
  
  use GenServer

  ## Client API

  @doc """
  Starts the nice update server.
  """
  def start_link(nice_server, opts \\ []) do
    GenServer.start_link(__MODULE__, {:ok, nice_server}, opts)
  end


  @doc """
  Update the last updated time

  Returns `{:ok}` 
  """
  def check_for_update(server) do
    GenServer.call(server, {:check_for_update})
  end

  ## Server API
  @doc """
  There is no initial state
  """
  def init({:ok, nice_server}) do
    update_rankings(nice_server)
    :timer.apply_interval(2*60*1000, ElixirADN.Filter.NiceUpdateServer, :check_for_update, [self])
    {:ok, %{nice_server: nice_server}}
  end

  @doc """
  Get the rank for a user and check to see if the rankings need to be
  updated
  """
  def handle_call({:check_for_update}, _from, state) do
    update_rankings(state.nice_server)
    {:reply, :ok, state}
  end

  defp update_rankings(nice_server) do
    NiceServer.mark_updating(nice_server)
    {:ok, ranking_array} = HTTPoison.get!("https://api.nice.social/user/nicesummary?nicerank=0.1", timeout: :infinity)
      |> ResultParser.convert_to(:map)
    
    ranking_array 
      |> Enum.map(fn(x) -> Map.put(x, "updated", true) end)
      |> Enum.each(fn(%{"user_id" => user_id}=x) -> NiceServer.update_user(nice_server, user_id, x) end)
  
    NiceServer.finish_updating(nice_server)
  end
end