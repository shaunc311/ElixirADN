defmodule ElixirADN.Model.Message do
	@doc ~S"""
	An elixir representation of the ADN message map
	{
	  "channel_id": "1",
	  "created_at": "2012-12-11T00:31:49Z",
	  "entities": {
	    "hashtags": [

	    ],
	    "links": [

	    ],
	    "mentions": [

	    ]
	  },
	  "html": "<span itemscope=\"https://app.net/schemas/Post\">Hello channel!</span>",
	  "id": "1",
	  "machine_only": false,
	  "num_replies": 0,
	  "source": {
	    "client_id": "UxUWrSdVLyCaShN62xZR5tknGvAxK93P",
	    "link": "https://app.net",
	    "name": "Test app"
	  },
	  "text": "Hello channel!",
	  "thread_id": "1",
	  "user": "...user object...",
	  "annotations": []

	}
	"""
	defstruct channel_id: "", created_at: "", entities: nil, html: "", id: "", machine_only: false, num_replies: -1, reply_to: nil, source: nil, text: "", thread_id: "", user: nil, annotations: []
end