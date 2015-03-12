defmodule ElixirADN.Model.Image do
  @doc ~S"""
  An elixir representation of the ADN image map found in the User map
  {
    "height": 200,
    "is_default": false,
    "url": "https://d2rfichhc2fb9n.cloudfront.net/image/5/aoveeP73f33UcFhyhqzn7VhwgS17InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvOTkvYTYvNDAvOTlhNjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0",
    "width": 200
  }
  """
  defstruct height: -1, is_default: false, url: "", width: -1
end