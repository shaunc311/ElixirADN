defmodule ElixirADN.Endpoints.FilterTest do
	use ExUnit.Case, async: false
  alias ElixirADN.Endpoints.Filter
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.Pagination
  alias ElixirADN.Endpoints.Parameters.UserParameters
  
  import Mock

  setup_all do 
  	body = File.read!("./test/elixir_adn/parser/posts.json")
		doc = %HTTPoison.Response{ status_code: 200, body: body, headers: [] }
  	{:ok, doc: doc}
  end

  test_with_mock "get filters", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Authorization", "Bearer token"}]) -> doc end] do

    {:ok, posts } = Filter.get("token")
    
    assert called HTTPoison.get!("https://api.app.net/filters", [{"Authorization", "Bearer token"}])
    assert Enum.count(posts) == 1
  end

end