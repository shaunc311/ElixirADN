defmodule ElixirADN.Helpers.ResponseHelperTest do
	use ExUnit.Case, async: false

  import Mock

	setup_all do 
    doc = %HTTPoison.Response{ status_code: 200, body: "", headers: [] }
    {:ok, doc: doc}
  end

  test_with_mock "respond to message", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> doc end] do
    result = ElixirADN.Helpers.ResponseHelper.respond("token", %ElixirADN.Model.Response{text: "response"}, %ElixirADN.Model.Message{text: "blah", channel_id: "hi", id: "15"})
    expected_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Message{text: "response", reply_to: "15", channel_id: "hi"})
    
    assert result == doc
    assert called HTTPoison.post!("https://api.app.net/channels/hi/messages", expected_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end

  test_with_mock "respond to post", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> doc end] do
    result = ElixirADN.Helpers.ResponseHelper.respond("token", %ElixirADN.Model.Response{text: "response"}, %ElixirADN.Model.Post{text: "blah", id: "15"})
    expected_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Post{text: "response", reply_to: "15"})
    
    assert result == doc
    assert called HTTPoison.post!("https://api.app.net/posts", expected_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end
end