defmodule ElixirADN.Model.Post do
	@doc ~S"""
	An elixir representation of the ADN post map
	{
	  "canonical_url": "https://alpha.app.net/adn/post/914440",
	  "created_at": "2012-10-11T19:48:40Z",
	  "entities": {
	    "hashtags": [
	      {
	        "len": 8,
	        "name": "adnhack",
	        "pos": 90
	      }
	    ],
	    "links": [
	      {
	        "len": 29,
	        "pos": 100,
	        "text": "http://appnet.eventbrite.com/",
	        "url": "http://appnet.eventbrite.com/"
	      }
	    ],
	    "mentions": [

	    ]
	  },
	  "html": "<span itemscope=\"https://app.net/schemas/Post\">If you're in San Francisco on Saturday October 20 and Sunday October 21 come to the first <span data-hashtag-name=\"adnhack\" itemprop=\"hashtag\">#adnhack</span> => <a href=\"http://appnet.eventbrite.com/\">http://appnet.eventbrite.com/</a></span>",
	  "id": "914440",
	  "machine_only": false,
	  "num_replies": 1,
	  "num_reposts": 3,
	  "num_stars": 3,
	  "source": {
	    "client_id": "caYWDBvjwt2e9HWMm6qyKS6KcATHUkzQ",
	    "link": "https://alpha.app.net",
	    "name": "Alpha"
	  },
	  "text": "If you're in San Francisco on Saturday October 20 and Sunday October 21 come to the first #adnhack => http://appnet.eventbrite.com/",
	  "thread_id": "914440",
	  "user": "...user object...",
	  "you_reposted": false,
	  "you_starred": false,
	  "annotations": [
	    {
	      "type": "net.app.core.geolocation",
	      "value": {
	        "latitude": 74.0064,
	        "longitude": 40.7142
	      }
	    }
	  ],
	  "reposters": [
	    "...user objects..."
	  ],
	  "starred_by": [
	    "...user objects..."
	  ]
	}
	"""
	defstruct canonical_url: "", created_at: "", entities: nil, html: "", id: "", machine_only: false, num_replies: -1, num_reposts: -1, num_stars: -1, source: nil, text: "", thread_id: "", user: nil, you_reposted: false, you_starred: false, annotations: [], reposters: [], starred_by: []
end