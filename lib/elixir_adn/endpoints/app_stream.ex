defmodule ElixirADN.Endpoints.AppStream do
  alias ElixirADN.Endpoints.Parameters.AppStreamParameters
  alias ElixirADN.Endpoints.StreamServers.AppStreamServer

  @moduledoc  ~S"""
  A customized view of the global events happening on App.net that is 
  streamed to the client instead of polling.  Full documentation
  can be found here:
 
  https://developers.app.net/reference/resources/app-stream/

  You can create up to 5 streams per App token.
  """

  @doc ~S"""
  Streams ADN.  Based on the post by Benjamin Tam:
  http://benjamintan.io/blog/2015/02/05/how-to-build-streams-in-elixir-easily-with-stream-resource-awesomeness/
  """
  def stream(%AppStreamParameters{} = stream_parameters, app_token) do
    Stream.resource( 
      #The initial state function
      fn -> create_stream(app_token, stream_parameters) end,
      #The "next" function
      fn(x) -> stream_for_result(x) end,
      #The close function
      fn(x) -> close_stream(x) end
    )
  end

  defp create_stream(app_token, stream_parameters) do
    #create a stream and get the connection id (assuming the stream creates correctly, otherwise crash)
    {:ok, pid} = AppStreamServer.start_link()
    :ok = AppStreamServer.start_streaming(pid, app_token, stream_parameters)
    #Return the PID so the other stream functions can access the server
    pid
  end

  #Delete the stream
  defp close_stream(pid) do
    #delete it
    AppStreamServer.close_stream(pid)
  end

  #Get the next item in the stream
  defp stream_for_result(pid) do
    AppStreamServer.get_next_item(pid)
  end
end