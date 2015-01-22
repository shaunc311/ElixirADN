defmodule ElixirADN.Description do
	@doc ~S"""
	An elixir representation of the ADN description map found in the User map
	{
	  "entities": {
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
	  },
	  "html": "<span itemscope=\"https://app.net/schemas/Post\">Updating you on changes to the <a href=\"http://App.net\">App.net</a> API</span>",
	  "text": "Updating you on changes to the App.net API"
	}
	"""
	defstruct entities: nil, html: "", text: ""
end