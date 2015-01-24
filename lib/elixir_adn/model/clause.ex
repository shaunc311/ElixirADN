defmodule ElixirADN.Model.Clause do
	@doc ~S"""
	An elixir representation of the ADN clause map
	{
    "field": "/data/entities/hashtags/*/name",
    "object_type": "post",
    "operator": "matches",
    "value": "rollout"
  }
	"""
	defstruct field: "", object_type: "", operator: "", value: ""
end