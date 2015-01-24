defmodule ElixirADN.Model.Filter do
	@doc ~S"""
	An elixir representation of the ADN filter map
	{
    "clauses": [
      {
        "field": "/data/entities/hashtags/*/name",
        "object_type": "post",
        "operator": "matches",
        "value": "rollout"
      }
    ],
    "id": "1",
    "match_policy": "include_any",
    "name": "Posts about rollouts",
    "owner": "...user object..."
  }
	"""
	defstruct clauses: [], id: "", match_policy: "", name: "", owner: nil
end