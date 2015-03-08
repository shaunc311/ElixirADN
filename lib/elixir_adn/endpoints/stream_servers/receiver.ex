defmodule ElixirADN.Endpoints.StreamServers.Receiver do
	alias ElixirADN.Parser.ResultParser
	
	@moduledoc ~S"""
	A module to handle the common "waiting" code between user streams
	and app streams
	"""

	@doc ~S"""
	Wait for AsynchChunk with data in them
	"""
	def receive_message() do
		receive do
    	#If it's a header (it shouldn't be) just continue waiting
    	%HTTPoison.AsyncHeaders{} ->
				receive_message()
			#if it's status, just keep waiting
			%HTTPoison.AsyncStatus{} ->
				receive_message()
			#If it's an empty chunk, continue waiting
			%HTTPoison.AsyncChunk{chunk: ""} ->
				#Call it again
				receive_message()
			#If it's a valid chunk, process it and if it's
			#an item we care about add it to the stream or
			#continue waiting
			%HTTPoison.AsyncChunk{chunk: chunk} ->
				#basically keep reading the stream until
				#all the chunks are a full object
				item = get_all_chunks(chunk)
					|> process_chunk()
				case item do
					nil -> receive_message()
					#data isn't an array, so make it one to match the rest of 
					#the endpoints
					x when is_list(x) -> item
					y -> [y]
				end
				
			#End of the stream, but shouldn't happen with ADN streams
			%HTTPoison.AsyncEnd{} ->
				IO.puts "end"
				:halt
			#Something else (included for debugging)
			var ->
				IO.puts "unknown value"
				IO.inspect var
				:halt
		end
	end


	#Since a chunk is not guaranteed to be an entire
	#object, keep reading until we get a \r\n 
	defp get_all_chunks(acc) do
  	case String.ends_with?(acc, "\r\n") do
			true -> 
				acc
			false ->
				receive do
					%HTTPoison.AsyncChunk{chunk: chunk} -> get_all_chunks(acc <> chunk)
					%HTTPoison.AsyncEnd{} -> IO.puts "End?!"
				end
		end
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