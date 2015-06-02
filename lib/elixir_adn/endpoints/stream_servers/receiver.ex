defmodule ElixirADN.Endpoints.StreamServers.Receiver do
  alias ElixirADN.Parser.ResultParser
  require Logger
  @moduledoc ~S"""
  A module to handle the common "waiting" code between user streams
  and app streams
  """

  @doc ~S"""
  Wait for AsynchChunk with data in them
  """
  def receive_message(main, hackney_ref, acc \\ "") do
    IO.puts "waiting"
    receive do
      #If it's a header (it shouldn't be) just continue waiting
      %HTTPoison.AsyncHeaders{id: ^hackney_ref} = headers->
      #{:hackney_response, ref,{:headers, headers} } ->
        receive_message(main, hackney_ref)
      #if it's status, just keep waiting
      %HTTPoison.AsyncStatus{id: ^hackney_ref} = status ->
      #{:hackney_response, ref, {:status, status_int, reason}} ->
        receive_message(main, hackney_ref)
      #End of the stream, but shouldn't happen with ADN streams
      #{:hackney_response, ref, :done} ->
      %HTTPoison.AsyncEnd{id: ^hackney_ref} ->
        IO.puts "end"
        :halt
      #If it's an empty chunk, continue waiting
      %HTTPoison.AsyncChunk{id: ^hackney_ref, chunk: ""} ->
      #{:hackney_response, ref, ""} ->
        #Call it again
        receive_message(main, hackney_ref)
      %HTTPoison.AsyncChunk{id: ^hackney_ref, chunk: "\r\n"} ->
      #{:hackney_response, ref, "\r\n"} ->
        #Call it again
        receive_message(main, hackney_ref)
      #If it's a valid chunk, process it and if it's
      #an item we care about add it to the stream or
      #continue waiting
      %HTTPoison.AsyncChunk{id: ^hackney_ref, chunk: chunk} ->
      #{:hackney_response, ref, chunk} ->
        #basically keep reading the stream until
        #all the chunks are a full object
        piece = acc <> chunk
        case String.ends_with?(piece, "\r\n") do
          false -> receive_message(main, hackney_ref, piece)
          true -> spawn_link(fn -> parse_items(main, hackney_ref, piece) end)
        end
      
      #Something else (included for debugging)
      var ->
        IO.puts "unknown value"
        IO.inspect var
        :halt
    end
  end
 
  def parse_items(main, hackney_ref, piece) do
    item = process_chunk(piece)
    items = case item do
      nil -> receive_message(main, hackney_ref)
      #data isn't an array, so make it one to match the rest of 
      #the endpoints
      x when is_list(x) -> item
      y -> [y]
    end
    send(main, {:parsed, items})
  end

  #\r\n is the item seperator so return nil so it gets skipped
  defp process_chunk("\r\n") do
    nil
  end

  #Decode an item from the stream
  defp process_chunk(chunk_json) do
    ResultParser.convert_to(chunk_json, :stream)
  end
end