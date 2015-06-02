defmodule ElixirADN.Endpoints.StreamServers.AppStreamServerTest do
  use ExUnit.Case, async: false

  import Mock

  setup do 
    {:ok, server_pid}  = ElixirADN.Endpoints.StreamServers.AppStreamServer.start_link
    doc = %HTTPoison.Response{ status_code: 200, body:  "{\"data\":{\"endpoint\":\"1\", \"id\": \"12\"}}", headers: [] }
    {:ok, stream_server: server_pid, subscription: doc}
  end

  test_with_mock "start streaming calls subscription endpoints", %{stream_server: stream_server, subscription: subscription}, HTTPoison, [:passthrough],
    [post!: fn(_url, _body, _headers) -> subscription end,
     get: fn(_url,_body,_headers) -> {:ok, %HTTPoison.AsyncResponse{id: 10}} end ] do

   result = ElixirADN.Endpoints.StreamServers.AppStreamServer.start_streaming(stream_server, "token", %ElixirADN.Endpoints.Parameters.AppStreamParameters{})
   
   assert result == :ok
   assert called HTTPoison.get("1",  [{"Authorization", "Bearer token"}], timeout: :infinity, stream_to: stream_server)
  end

  test "close an unopened stream", %{stream_server: stream_server} do
    result = ElixirADN.Endpoints.StreamServers.AppStreamServer.close_stream(stream_server)

    assert result == {:ok}
  end

  
end