defmodule ElixirADN.Model.DerivedFiles do
	@doc ~S"""
	An elixir representation of the ADN derived files map
	{
    "image_thumb_200s": {
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
    },
    "image_thumb_960r": {
      "image_info": {
        "width": 600,
        "height": 800
      },
      "name": "filename_image_thumb_960r.png",
      "mime_type": "image/png",
      "size": 140173,
      "sha1": "57004b55119002f551be5b9f2d5439dd4ad1234a",
      "url": "https://example.com/thumbnail_960r.png",
      "url_expires": "2013-01-25T03:00:00Z"
    }
  }
	"""
	defstruct image_thumb_200s: nil, image_thumb_960r: nil
end