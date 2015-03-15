defmodule ElixirADN.Endpoints.PostTest do
  use ExUnit.Case, async: false
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.Pagination
  import Mock

  setup_all do 
    body = File.read!("./test/elixir_adn/parser/posts.json")
    doc = %HTTPoison.Response{ status_code: 200, body: body, headers: [] }
    {:ok, doc: doc}
  end

  test_with_mock "create post", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> doc end] do
    result = ElixirADN.Endpoints.Post.create_post(%ElixirADN.Model.Post{text: "blah"}, "token")
    expected_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{text: "blah"})
    
    assert result == doc
    assert called HTTPoison.post!("https://api.app.net/posts", expected_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end

  test_with_mock "read post", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do
    {:ok, posts} = ElixirADN.Endpoints.Post.get_posts(%PostParameters{}, %Pagination{})
    
    assert called HTTPoison.get!("https://api.app.net/posts/stream/global", [{"Content-Type", "application/json"}])
    assert Enum.count(posts) == 1
  end
end