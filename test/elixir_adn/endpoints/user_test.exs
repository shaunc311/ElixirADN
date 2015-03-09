defmodule ElixirADN.Endpoints.UserTest do
  use ExUnit.Case, async: false
  alias ElixirADN.Endpoints.User
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.Pagination
  alias ElixirADN.Endpoints.Parameters.UserParameters
  
  import Mock

  setup_all do 
  	body = File.read!("./test/elixir_adn/parser/posts.json")
		doc = %HTTPoison.Response{ status_code: 200, body: body, headers: [] }
  	user_body = File.read!("./test/elixir_adn/parser/users.json")
    user_doc = %HTTPoison.Response{ status_code: 200, body: user_body, headers: [] }
    {:ok, doc: doc, userdoc: user_doc}
  end

  test_with_mock "get posts for account", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_posts("@shauncollins", %PostParameters{}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts", [{"Content-Type", "application/json"}])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts for account with muted", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?include_muted=1", [{"Content-Type", "application/json"}])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get mentions", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Authorization", "Bearer token"},{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_mentions("@shauncollins", "token", %PostParameters{include_muted: true}, %Pagination{})
    
    assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/mentions?include_muted=1", [{"Authorization", "Bearer token"},{"Content-Type", "application/json"}])
    assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_posts("@shauncollins", %PostParameters{}, %Pagination{count: 5})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?count=5", [{"Content-Type", "application/json"}])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count and muted", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{count: 5})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?include_muted=1&count=5", [{"Content-Type", "application/json"}])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts by id number", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> doc end] do

    posts = User.get_posts(410, %PostParameters{}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/410/posts", [{"Content-Type", "application/json"}])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "bad request", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 400, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :bad_request
    assert message == "hi"
  end

  test_with_mock "unauthorized", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 401, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :unauthorized
    assert message == "hi"
  end

  test_with_mock "forbidden", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 403, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :forbidden
		assert message == "hi"
  end

  test_with_mock "not found", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 404, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :not_found
    assert message == "hi"
  end

  test_with_mock "method not allowed", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 405, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :method_not_allowed
    assert message == "hi"
  end

  test_with_mock "too many requests", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 429, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :too_many_requests
    assert message == "hi"
  end

  test_with_mock "internal server error", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url,[{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 500, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :internal_server_error
    assert message == "hi"
  end

  test_with_mock "insufficient storage", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> %HTTPoison.Response{ status_code: 507, body: "{\"meta\":{\"error_message\":\"hi\"}}"} end] do

    {error, code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert error == :error
    assert code == :insufficient_storage
    assert message == "hi"
  end

  test_with_mock "get account", %{userdoc: userdoc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> userdoc end] do

    users = User.get("@shauncollins", %UserParameters{})
    
    assert called HTTPoison.get!("https://api.app.net/users/@shauncollins", [{"Content-Type", "application/json"}])
    assert Enum.count(users) == 2
  end

  test_with_mock "get account by id", %{userdoc: userdoc}, HTTPoison, [:passthrough],
    [get!: fn(_url, [{"Content-Type", "application/json"}]) -> userdoc end] do

    users = User.get(10, %UserParameters{})
    
    assert called HTTPoison.get!("https://api.app.net/users/10", [{"Content-Type", "application/json"}])
    assert Enum.count(users) == 2
  end
end