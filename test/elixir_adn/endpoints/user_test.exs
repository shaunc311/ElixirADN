defmodule ElixirADN.Endpoints.UserTest do
  use ExUnit.Case, async: false
  alias ElixirADN.Endpoints.User
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.Pagination

  import Mock

  setup_all do 
  	body = File.read!("./test/elixir_adn/parser/posts.json")
		doc = %HTTPoison.Response{ status_code: 200, body: body, headers: [] }
  	{:ok, doc: doc}
  end

  test_with_mock "get posts for account", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> doc end] do

    {:ok, posts }= User.get_posts("@shauncollins", %PostParameters{}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts", [])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts for account with muted", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?include_muted=1", [])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{}, %Pagination{count: 5})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?count=5", [])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count and muted", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{count: 5})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/@shauncollins/posts?include_muted=1&count=5", [])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts by id number", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> doc end] do

    {:ok, posts } = User.get_posts(410, %PostParameters{}, %Pagination{})
  	
  	assert called HTTPoison.get!("https://api.app.net/users/410/posts", [])
  	assert Enum.count(posts) == 1
  end

  test_with_mock "no content", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 204} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :no_content
  end

  test_with_mock "bad request", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 400} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :bad_request
  end

  test_with_mock "unauthorized", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 401} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :unauthorized
  end

  test_with_mock "forbidden", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 403} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :forbidden
  end

  test_with_mock "not found", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 404} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :not_found
  end

  test_with_mock "method not allowed", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 405} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :method_not_allowed
  end

  test_with_mock "too many requests", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 429} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :too_many_requests
  end

  test_with_mock "internal server error", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 500} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :internal_server_error
  end

  test_with_mock "insufficient storage", %{doc: doc}, HTTPoison, [:passthrough],
    [get!: fn(_url, []) -> %HTTPoison.Response{ status_code: 507} end] do

    {code, message } = User.get_posts("@user", %PostParameters{ include_muted: true, include_annotations: false }, %Pagination{count: 5, before_id: 2} )
		assert code == :error
		assert message == :insufficient_storage
  end

  test "invalid parameter objects" do
  	{code, message } = User.get_posts("@user", %{ include_muted: true, include_annotations: false }, %{count: 5, before_id: 2} )
		assert code == :error
		assert message == :invalid_parameter_to_parse
  end

  test "invalid boolean parameter" do
  	{code, message} = User.get_posts("@user", %PostParameters{ include_muted: 5 }, %Pagination{} )
		assert code == :error
		assert message == {:invalid_boolean_value, :include_muted, 5}
  end

  test "invalid range on count" do
  	{code, message} = User.get_posts("@user", %PostParameters{ include_muted: true }, %Pagination{count: 201} )
		assert code == :error
		assert message == {:value_out_of_range, :count, 201}
	end

	test "negative invalid range on count" do
		{code, message} = User.get_posts("@user", %PostParameters{ include_muted: true }, %Pagination{count: -201} )
		assert code == :error
		assert message == {:value_out_of_range, :count, -201}
	end

end