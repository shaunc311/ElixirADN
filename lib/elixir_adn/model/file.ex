defmodule ElixirADN.Model.File do
  @doc ~S"""
  An elixir representation of the ADN file map
  {
    "complete": true,
    "created_at": "2013-01-28T18:31:18Z",
    "derived_files": {
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
    },
    "file_token": "auCj3h64JZrhQ9aJdmwre3KP-QL9UtWHYvt5tj_64rUJWemoIV2W8eTJv9NMaGpBFk-BbU_aWA26Q40w4jFhiPBpnIQ_lciLwfh6o8YIAQGEQziksUMxZo7gOHJ_-niw3l3MZCh7QRWzqNGpiVaUEptfKO0fETrZ8bJjDa61234a",
    "id": "1",
    "image_info": {
      "width": 600,
      "height": 800
    },
    "kind": "image",
    "mime_type": "image/png",
    "name": "filename.png",
    "sha1": "ef0ccae4d36d4083b53e121a6cf9cc9d7ac1234a",
    "size": 172393,
    "source": {
      "name": "Clientastic for iOS",
      "link": "http://app.net",
      "client_id": "98765zyxw"
    },
    "total_size": 346369,
    "type": "com.example.test",
    "url": "https://...",
    "url_expires": "2013-01-25T03:00:00Z",
    "user": "...user object...",
    "annotations": []
  }
  """
  defstruct complete: false, created_at: "", derived_files: nil, file_token: "", id: "", image_info: nil, kind: "", mime_type: "", name: "", sha1: "", size: -1, source: nil, total_size: -1, type: "", url: "", url_expires: "", user: nil, annotations: []
end