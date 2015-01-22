defmodule ElixirADN.User do
	@doc ~S"""
	An elixir representation of the ADN user map
	{
	  "avatar_image": {
	    "height": 200,
	    "is_default": false,
	    "url": "https://d2rfichhc2fb9n.cloudfront.net/image/5/aoveeP73f33UcFhyhqzn7VhwgS17InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvOTkvYTYvNDAvOTlhNjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0",
	    "width": 200
	  },
	  "canonical_url": "https://alpha.app.net/adnapi",
	  "counts": {
	    "followers": 1549,
	    "following": 12,
	    "posts": 115,
	    "stars": 4
	  },
	  "cover_image": {
	    "height": 260,
	    "is_default": true,
	    "url": "https://d2rfichhc2fb9n.cloudfront.net/image/5/kZ-JRmTbmd3WVPswTJ8Nwxzkf917InMiOiJzMyIsImIiOiJ0YXBwLWFzc2V0cyIsImsiOiJpL1UvaS9ZL1VpWW5xRFNvTUtyTEhLNXA0OHN2NkxmTmRVMC5qcGciLCJvIjoiIn0",
	    "width": 960
	  },
	  "created_at": "2012-08-10T22:40:12Z",
	  "description": {
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
	  },
	  "id": "1558",
	  "locale": "en_US",
	  "name": "ADN API",
	  "timezone": "America/Los_Angeles",
	  "type": "human",
	  "username": "adnapi",
	  "verified_domain": "developers.app.net",
	  "follows_you": false,
	  "you_blocked": false,
	  "you_follow": false,
	  "you_muted": false,
	  "you_can_subscribe": true,
	  "you_can_follow": true,
	  "annotations": [
	    {
	      "type": "net.app.core.directory.blog",
	      "value": {
	        "url": "http://daltoncaldwell.com/"
	      }
	    }
	  ]
	}
	"""
	defstruct avatar_image: nil, canonical_url: "", counts: nil, cover_image: nil, created_at: nil, description: nil, id: "", locale: "", name: "", timezone: "", type: "", username: "", verified_domain: "", follow_you: false, you_blocked: false, you_follow: false, you_muted: false, you_can_subscribe: false, you_can_follow: false, annotations: []
end