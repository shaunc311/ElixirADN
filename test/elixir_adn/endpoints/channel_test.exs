defmodule ElixirADN.Endpoints.ChannelTest do
	use ExUnit.Case, async: false

  import Mock

  setup_all do 
  	doc = %HTTPoison.Response{ status_code: 200, body: "", headers: [] }
  	{:ok, doc: doc}
  end

  test_with_mock "create message", %{doc: doc}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> doc end] do
    result = ElixirADN.Endpoints.Channel.create_message("token", %ElixirADN.Model.Message{text: "blah", channel_id: "hi"})
  	expected_body = ElixirADN.Endpoints.Parameters.Encoder.generate_json(%ElixirADN.Model.Message{text: "blah", channel_id: "hi"})
    
  	assert result == doc
  	assert called HTTPoison.post!("https://api.app.net/channels/hi/messages", expected_body, [{"Authorization", "Bearer token"}, {"Content-Type", "application/json"}])
  end
end