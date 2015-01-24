defmodule ElixirADN.Model.Channel do
	@doc ~S"""
	An elixir representation of the ADN channel map
	{
	  "counts": {
	    "messages": 42,
	    "subscribers": 43
	  },
	  "has_unread": false,
	  "id": "1",
	  "owner": "...user object...",
	  "is_inactive": false,
	  "readers": {
	    "any_user": false,
	    "immutable": false,
	    "public": true,
	    "user_ids": [

	    ],
	    "you": true
	  },
	  "editors": {
	    "any_user": false,
	    "immutable": false,
	    "public": false,
	    "user_ids": [

	    ],
	    "you": true
	  },
	  "recent_message_id": "231",
	  "recent_message": "...message object...",
	  "type": "com.example.channel",
	  "writers": {
	    "any_user": false,
	    "immutable": false,
	    "public": false,
	    "user_ids": [
	      "2",
	      "3"
	    ],
	    "you": true
	  },
	  "you_can_edit": true,
	  "you_subscribed": true,
	  "you_muted": false,
	  "marker": "...marker object..."
	}
	"""
	defstruct counts: nil, has_unread: false, id: "", owner: nil, is_inactive: false, readers: nil, editors: nil, recent_message_id: "", recent_message: nil, type: "", writers: nil, you_can_edit: false,  you_subscribed: false, you_muted: false, marker: nil 
end