defmodule ElixirADN.Entities do
	@doc ~S"""
	An elixir representation of the ADN entities map found in the User map
	{
    "hashtags": [

    ],
    "links": [
      {
        "len": 7,
        "pos": 31,
        "text": "App.net",
        "url": "http://App.net"
      }
    ],
    "mentions": [

    ]
  }
	"""
	defstruct hashtags: [], links: [], mentions: []
end