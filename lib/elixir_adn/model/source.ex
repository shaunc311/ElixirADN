defmodule ElixirADN.Model.Source do
	@doc ~S"""
	An elixir representation of the ADN source map found in the Post map
	{
    "client_id": "caYWDBvjwt2e9HWMm6qyKS6KcATHUkzQ",
    "link": "https://alpha.app.net",
    "name": "Alpha"
  }
	"""
	defstruct client_id: "", link: "", name: ""
end