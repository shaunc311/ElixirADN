defmodule ElixirADN.Parser.BaseParserTest do
  use ExUnit.Case, async: false
  #doctest Parser

  setup do 
  	doc = ~S"""
  {
  	"data": [
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
      "user": {
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
      },
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
        {
          "id": "7"
        },
        {
          "id": "8"
        }
      ],
      "starred_by": [
        {
          "id": "9"
        }
      ]
    }
  ],
  "meta": {
    "code": 200,
    "more": false,
    "min_id": "914440",
    "max_id": "914440"
  }
}
	"""
  	{:ok, doc: doc}
  end

  test "parse post", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    assert post.canonical_url == "https://alpha.app.net/adn/post/914440"
    assert post.created_at == "2012-10-11T19:48:40Z"
    assert post.html == "<span itemscope=\"https://app.net/schemas/Post\">If you're in San Francisco on Saturday October 20 and Sunday October 21 come to the first <span data-hashtag-name=\"adnhack\" itemprop=\"hashtag\">#adnhack</span> => <a href=\"http://appnet.eventbrite.com/\">http://appnet.eventbrite.com/</a></span>"
    assert post.id == "914440"
    assert post.machine_only == false
    assert post.num_replies == 1
    assert post.num_reposts == 3
    assert post.num_stars == 3   
    assert post.text == "If you're in San Francisco on Saturday October 20 and Sunday October 21 come to the first #adnhack => http://appnet.eventbrite.com/"
    assert post.thread_id == "914440"
    assert post.you_reposted == false
    assert post.you_starred == false

  end

  test "parse entities", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    %ElixirADN.Model.Entities{ hashtags: [hashtag], links: [link], mentions: mentions} = post.entities
    assert hashtag.len == 8
    assert hashtag.name == "adnhack"
    assert hashtag.pos == 90
    assert link.len == 29
    assert link.pos == 100
    assert link.text == "http://appnet.eventbrite.com/"
    assert link.url == "http://appnet.eventbrite.com/"
    assert mentions == []
  end
  
  test "parse source", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    %ElixirADN.Model.Source{ client_id: client_id, link: link, name: name} = post.source
    assert client_id == "caYWDBvjwt2e9HWMm6qyKS6KcATHUkzQ"
    assert link == "https://alpha.app.net"
    assert name == "Alpha"
  end

  test "parse user", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    %ElixirADN.Model.Image{height: avatar_image_height, is_default: avatar_image_is_default, url: avatar_image_url, width: avatar_image_width} = post.user.avatar_image
    assert avatar_image_height == 200
    assert avatar_image_is_default == false
    assert avatar_image_url == "https://d2rfichhc2fb9n.cloudfront.net/image/5/aoveeP73f33UcFhyhqzn7VhwgS17InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvOTkvYTYvNDAvOTlhNjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0"
    assert avatar_image_width == 200

    assert post.user.canonical_url == "https://alpha.app.net/adnapi"

    %ElixirADN.Model.UserCounts{followers: followers, following: following, posts: post_count, stars: stars} = post.user.counts
    assert followers == 1549
    assert following == 12
    assert post_count == 115
    assert stars == 4

    %ElixirADN.Model.Image{height: cover_image_height, is_default: cover_image_is_default, url: cover_image_url, width: cover_image_width} = post.user.cover_image
    assert cover_image_height == 260
    assert cover_image_is_default == true
    assert cover_image_url == "https://d2rfichhc2fb9n.cloudfront.net/image/5/kZ-JRmTbmd3WVPswTJ8Nwxzkf917InMiOiJzMyIsImIiOiJ0YXBwLWFzc2V0cyIsImsiOiJpL1UvaS9ZL1VpWW5xRFNvTUtyTEhLNXA0OHN2NkxmTmRVMC5qcGciLCJvIjoiIn0"
    assert cover_image_width == 960

    assert post.user.created_at == "2012-08-10T22:40:12Z"
  
    %ElixirADN.Model.Description{entities: %ElixirADN.Model.Entities{hashtags: hashtags, links: [link], mentions: mentions}, html: html, text: text} = post.user.description
    assert hashtags == []
    assert link.len == 7
    assert link.pos == 31
    assert link.text == "App.net"
    assert link.url == "http://App.net"
    assert mentions == []
    assert html == "<span itemscope=\"https://app.net/schemas/Post\">Updating you on changes to the <a href=\"http://App.net\">App.net</a> API</span>"
    assert text == "Updating you on changes to the App.net API"

    assert post.user.id == "1558"
    assert post.user.locale == "en_US"
    assert post.user.name ==  "ADN API"
    assert post.user.timezone == "America/Los_Angeles"
    assert post.user.type == "human"
    assert post.user.username == "adnapi"
    assert post.user.verified_domain == "developers.app.net"
    assert post.user.follows_you == false 
    assert post.user.you_blocked == false
    assert post.user.you_follow == false
    assert post.user.you_muted == false
    assert post.user.you_can_subscribe == true
    assert post.user.you_can_follow == true
    
    [%ElixirADN.Model.Annotation{ type: annotation_type, value: annotation_value}] = post.user.annotations
    assert annotation_type == "net.app.core.directory.blog"
    assert annotation_value ==  %{"url" => "http://daltoncaldwell.com/"}
  end

  test "parse annotations", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.Annotation{ type: annotation_type, value: annotation_value}] = post.annotations
    assert annotation_type == "net.app.core.geolocation"
    assert annotation_value ==  %{"latitude" => 74.0064, "longitude" => 40.7142}

    assert length(post.reposters) == 2

  end
  test "parse reposters", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.User{id: reposter_id_1}, %ElixirADN.Model.User{id: reposter_id_2}] = post.reposters
    assert reposter_id_1 == "7"
    assert reposter_id_2 == "8"
  end

  test "parse starred_by", %{doc: doc} do
    {result, map} = ElixirADN.Parser.Parser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.Parser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.User{id: star_id}] = post.starred_by
    assert star_id == "9"
  end

  test "parse invalid data" do
    {result, message} = ElixirADN.Parser.Parser.parse(:posts, 123)
    assert result == :error
    assert message == :invalid_data_to_parse
  end

end
