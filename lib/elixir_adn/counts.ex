defmodule ElixirADN.Counts do
	@doc ~S"""
	An elixir representation of the ADN counts map found in the User map
	{
    "followers": 1549,
	  "following": 12,
	  "posts": 115,
	  "stars": 4
	}
	"""
	defstruct followers: -1, following: -1, posts: -1, stars: -1
end