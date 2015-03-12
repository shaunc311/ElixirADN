defmodule ElixirADN.Model.ImageThumb do
  @doc ~S"""
  An elixir representation of the ADN image thumbmap
  {
    "image_info": {
      "width": 200,
      "height": 200
    },
    "name": "filename_image_thumb_200s.png",
    "mime_type": "image/png",
    "sha1": "be91cb06d69df13bb103a359ce70cf9fba31234a",
    "size": 33803,
    "url": "https://example.com/thumbnail_200s.png",
    "url_expires": "2013-01-25T03:00:00Z"
  }
  """
  defstruct image_info: nil, name: "", mime_type: "", sha1: "", size: -1, url: "", url_expires: ""
end