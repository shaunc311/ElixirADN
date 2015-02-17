defmodule ElixirADN.Endpoints.PostTest do
	use ExUnit.Case, async: false

  import Mock

  setup_all do 
  	doc = %HTTPoison.Response{ status_code: 200, body: "", headers: [] }
  	{:ok, doc: doc}
  end

  test_with_mock "create post", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> doc end] do
    result = ElixirADN.Endpoints.Post.create_post("token", %ElixirADN.Model.Post{text: "blah"})
  	expected_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{text: "blah"})
    
  	assert result == doc
  	assert called HTTPoison.post!("https://api.app.net/posts", expected_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end
end