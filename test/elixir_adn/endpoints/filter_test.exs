defmodule ElixirADN.Endpoints.FilterTest do
  use ExUnit.Case, async: false
  alias ElixirADN.Endpoints.Filter
  
  import Mock

  setup_all do 
    body = File.read!("./test/elixir_adn/parser/posts.json")
    doc = %HTTPoison.Response{ status_code: 200, body: body, headers: [] }
    {:ok, doc: doc}
  end

  test_with_mock "get filters", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}]) -> doc end] do

    {:ok, posts} = Filter.get("token")
    
    assert called HTTPoison.get!("https://api.app.net/filters", [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
    assert Enum.count(posts) == 1
  end

  test_with_mock "get a filter", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}]) -> doc end] do

    {:ok, posts} = Filter.get("token", "id")
    
    assert called HTTPoison.get!("https://api.app.net/filters/id", [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
    assert Enum.count(posts) == 1
  end

  test_with_mock "create a filter", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, [{"Authorization", "Bearer token"},{"Content-Type", "application/json"}]) -> doc end] do

    clause = %ElixirADN.Model.Clause{field: "/data/entities/hashtags/*/name", object_type: "post", operator: "matches", value: "Dragoon"}
    filter = %ElixirADN.Model.Filter{clauses: [clause], match_policy: "include_any", name: "DragoonHashtag"}
    Filter.create_filter("token", filter)
    
    filter_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(filter)
    assert called HTTPoison.post!("https://api.app.net/filters", filter_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end

end