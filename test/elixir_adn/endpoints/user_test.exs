defmodule ElixirADN.Endpoints.UserTest do
  use ExUnit.Case, async: false

  alias ElixirADN.Endpoints.User
  alias ElixirADN.Endpoints.Parameters.PostParameters
  alias ElixirADN.Endpoints.Parameters.Pagination

  import Mock

  setup_all do 
  	body = File.read!("./test/elixir_adn/parser/posts.json")
		doc = %HTTPotion.Response{ status_code: 200, body: body, headers: [] }
  	{:ok, doc: doc}
  end

  test_with_mock "get posts for account", %{doc: doc}, HTTPotion, [:passthrough],
    [get: fn(_url) -> doc end] do

    {:ok, posts }= User.get_posts("@shauncollins", %PostParameters{}, %Pagination{})
  	
  	assert called HTTPotion.get("https://api.app.net/users/@shauncollins/posts")
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts for account with muted", %{doc: doc}, HTTPotion, [:passthrough],
    [get: fn(_url) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{})
  	
  	assert called HTTPotion.get("https://api.app.net/users/@shauncollins/posts?include_muted=1")
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count", %{doc: doc}, HTTPotion, [:passthrough],
    [get: fn(_url) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{}, %Pagination{count: 5})
  	
  	assert called HTTPotion.get("https://api.app.net/users/@shauncollins/posts?count=5")
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts with count and muted", %{doc: doc}, HTTPotion, [:passthrough],
    [get: fn(_url) -> doc end] do

    {:ok, posts } = User.get_posts("@shauncollins", %PostParameters{include_muted: true}, %Pagination{count: 5})
  	
  	assert called HTTPotion.get("https://api.app.net/users/@shauncollins/posts?include_muted=1&count=5")
  	assert Enum.count(posts) == 1
  end

  test_with_mock "get posts by id number", %{doc: doc}, HTTPotion, [:passthrough],
    [get: fn(_url) -> doc end] do

    {:ok, posts } = User.get_posts(410, %PostParameters{}, %Pagination{})
  	
  	assert called HTTPotion.get("https://api.app.net/users/410/posts")
  	assert Enum.count(posts) == 1
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