defmodule ElixirADN.Parser.StatusParser do
	@moduledoc ~S"""
	Parse the status codes coming from ADN, listed here:
	https://developers.app.net/reference/make-request/responses/
	"""
	
	@doc ~S"""
	Validate the given response based on the status code.

	## Examples

			iex> ElixirADN.Parser.StatusParser.parse_status 200
			{:ok, :success}

			iex> ElixirADN.Parser.StatusParser.parse_status 204
			{:error, :no_content}

			iex> ElixirADN.Parser.StatusParser.parse_status 302
			{:ok, :found}

	    iex> ElixirADN.Parser.StatusParser.parse_status 400
	    {:error, :bad_request}

	    iex> ElixirADN.Parser.StatusParser.parse_status 401
	    {:error, :unauthorized}

	    iex> ElixirADN.Parser.StatusParser.parse_status 403
	    {:error, :forbidden}

	    iex> ElixirADN.Parser.StatusParser.parse_status 404
	    {:error, :not_found}

	    iex> ElixirADN.Parser.StatusParser.parse_status 405
	    {:error, :method_not_allowed}

	    iex> ElixirADN.Parser.StatusParser.parse_status 429
	    {:error, :too_many_requests}

	    iex> ElixirADN.Parser.StatusParser.parse_status 500
	    {:error, :internal_server_error}

	    iex> ElixirADN.Parser.StatusParser.parse_status 507
	    {:error, :insufficient_storage}

	"""
	def parse_status(200), do: {:ok, :success}
	def parse_status(204), do: {:error, :no_content}
	def parse_status(302), do: {:ok, :found}
	def parse_status(400), do: {:error, :bad_request}
	def parse_status(401), do: {:error, :unauthorized}
	def parse_status(403), do: {:error, :forbidden}
	def parse_status(404), do: {:error, :not_found}
	def parse_status(405), do: {:error, :method_not_allowed}
	def parse_status(429), do: {:error, :too_many_requests}
	def parse_status(500), do: {:error, :internal_server_error}
	def parse_status(507), do: {:error, :insufficient_storage}
end