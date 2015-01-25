defmodule ElixirADN.Parser.BaseParserTest do
  use ExUnit.Case, async: false

  test "parse posts response" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
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

  test "parse post entities" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
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
  
  test "parse post source" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
    %ElixirADN.Model.Source{ client_id: client_id, link: link, name: name} = post.source
    assert client_id == "caYWDBvjwt2e9HWMm6qyKS6KcATHUkzQ"
    assert link == "https://alpha.app.net"
    assert name == "Alpha"
  end

  test "parse post user" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    

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

  test "parse post annotations" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.Annotation{ type: annotation_type, value: annotation_value}] = post.annotations
    assert annotation_type == "net.app.core.geolocation"
    assert annotation_value ==  %{"latitude" => 74.0064, "longitude" => 40.7142}

    assert length(post.reposters) == 2

  end
  test "parse post reposters" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.User{id: reposter_id_1}, %ElixirADN.Model.User{id: reposter_id_2}] = post.reposters
    assert reposter_id_1 == "7"
    assert reposter_id_2 == "8"
  end

  test "parse post starred_by" do
    doc = File.read!("./test/elixir_adn/parser/posts.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:posts, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Post{} = post] = ElixirADN.Parser.BaseParser.decode(:posts, map, ElixirADN.Model.Post)
    
    [%ElixirADN.Model.User{id: star_id}] = post.starred_by
    assert star_id == "9"
  end

   test "parse user response" do
    doc = File.read!("./test/elixir_adn/parser/users.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:users, doc)
    assert result == :ok
    
    [%ElixirADN.Model.User{} = user1, _user2] = ElixirADN.Parser.BaseParser.decode(:users, map, ElixirADN.Model.User)

    assert user1.canonical_url == "https://alpha.app.net/adnapi"
    assert user1.created_at == "2012-08-10T22:40:12Z"
    assert user1.id == "2"
    assert user1.locale == "en_US"
    assert user1.name ==  "ADN API"
    assert user1.timezone == "America/Los_Angeles"
    assert user1.type == "human"
    assert user1.username == "adnapi"
    assert user1.verified_domain == "developers.app.net"
    assert user1.follows_you == false 
    assert user1.you_blocked == false
    assert user1.you_follow == false
    assert user1.you_muted == false
    assert user1.you_can_subscribe == true
    assert user1.you_can_follow == true
    
    assert user1.annotations == nil
  end

  test "parse user avatar image" do
    doc = File.read!("./test/elixir_adn/parser/users.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:users, doc)
    assert result == :ok
    
    [%ElixirADN.Model.User{} = user1, _user2] = ElixirADN.Parser.BaseParser.decode(:users, map, ElixirADN.Model.User)

    %ElixirADN.Model.UserCounts{followers: followers, following: following, posts: post_count, stars: stars} = user1.counts
    assert followers == 1549
    assert following == 12
    assert post_count == 115
    assert stars == 4
  end

  test "parse user counts" do
    doc = File.read!("./test/elixir_adn/parser/users.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:users, doc)
    assert result == :ok
    
    [%ElixirADN.Model.User{} = user1, _user2] = ElixirADN.Parser.BaseParser.decode(:users, map, ElixirADN.Model.User)

    %ElixirADN.Model.Image{height: avatar_image_height, is_default: avatar_image_is_default, url: avatar_image_url, width: avatar_image_width} = user1.avatar_image
    assert avatar_image_height == 200
    assert avatar_image_is_default == false
    assert avatar_image_url == "https://d2rfichhc2fb9n.cloudfront.net/image/5/aoveeP73f33UcFhyhqzn7VhwgS17InMiOiJzMyIsImIiOiJhZG4tdXNlci1hc3NldHMiLCJrIjoiYXNzZXRzL3VzZXIvOTkvYTYvNDAvOTlhNjQwMDAwMDAwMDAwMC5wbmciLCJvIjoiIn0"
    assert avatar_image_width == 200
  end


  test "parse user cover image" do
    doc = File.read!("./test/elixir_adn/parser/users.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:users, doc)
    assert result == :ok
    
    [%ElixirADN.Model.User{} = user1, _user2] = ElixirADN.Parser.BaseParser.decode(:users, map, ElixirADN.Model.User)

    %ElixirADN.Model.Image{height: cover_image_height, is_default: cover_image_is_default, url: cover_image_url, width: cover_image_width} = user1.cover_image
    assert cover_image_height == 260
    assert cover_image_is_default == true
    assert cover_image_url == "https://d2rfichhc2fb9n.cloudfront.net/image/5/kZ-JRmTbmd3WVPswTJ8Nwxzkf917InMiOiJzMyIsImIiOiJ0YXBwLWFzc2V0cyIsImsiOiJpL1UvaS9ZL1VpWW5xRFNvTUtyTEhLNXA0OHN2NkxmTmRVMC5qcGciLCJvIjoiIn0"
    assert cover_image_width == 960
  end

  test "parse user description" do
    doc = File.read!("./test/elixir_adn/parser/users.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:users, doc)
    assert result == :ok
    
    [%ElixirADN.Model.User{} = user1, _user2] = ElixirADN.Parser.BaseParser.decode(:users, map, ElixirADN.Model.User)

    %ElixirADN.Model.Description{entities: %ElixirADN.Model.Entities{hashtags: hashtags, links: [link], mentions: mentions}, html: html, text: text} = user1.description
    assert hashtags == []
    assert link.len == 7
    assert link.pos == 31
    assert link.text == "App.net"
    assert link.url == "http://App.net"
    assert mentions == []
    assert html == "<span itemscope=\"https://app.net/schemas/Post\">Updating you on changes to the <a href=\"http://App.net\">App.net</a> API</span>"
    assert text == "Updating you on changes to the App.net API"
  end

  test "parse channel response" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    assert channel1.has_unread == false
    assert channel1.id == "2"
    assert channel1.is_inactive == false
    assert channel1.recent_message_id ==  "231"
    assert channel1.type == "com.example.channel"
    assert channel1.you_can_edit == true
    assert channel1.you_subscribed == true
    assert channel1.you_muted == false
  end

  test "parse channel counts" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    %ElixirADN.Model.ChannelCounts{messages: messages, subscribers: subscribers} = channel1.counts
    
    assert messages == 42
    assert subscribers == 43
  end

  test "parse channel readers" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    %ElixirADN.Model.ChannelPermissions{any_user: any_user, immutable: immutable, public: public, user_ids: user_ids, you: you} = channel1.readers
    
    assert any_user == false
    assert immutable == false
    assert public == true
    assert user_ids == []
    assert you == true
  end

  test "parse channel editors" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    %ElixirADN.Model.ChannelPermissions{any_user: any_user, immutable: immutable, public: public, user_ids: user_ids, you: you} = channel1.editors
    
    assert any_user == false
    assert immutable == false
    assert public == false
    assert user_ids == []
    assert you == true
  end

  test "parse channel writers" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    %ElixirADN.Model.ChannelPermissions{any_user: any_user, immutable: immutable, public: public, user_ids: user_ids, you: you} = channel1.writers
    
    assert any_user == false
    assert immutable == false
    assert public == false
    assert user_ids == []
    assert you == true
  end


  test "parse channel recent message" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    message = channel1.recent_message
    
    assert message.channel_id == "1"
    assert message.created_at == "2012-12-11T00:31:49Z"
    assert message.html == "<span itemscope=\"https://app.net/schemas/Post\">Hello channel!</span>"
    assert message.id == "1"
    assert message.machine_only == false
    assert message.num_replies == 0
    assert message.text == "Hello channel!"
    assert message.thread_id == "1"
  end

  test "parse channel recent message entities" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    message = channel1.recent_message
    %ElixirADN.Model.Entities{hashtags: hashtags, links: links, mentions: mentions} = message.entities
    assert hashtags == []
    assert links == []
    assert mentions == []    
  end

  test "parse channel recent message source" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    message = channel1.recent_message
    %ElixirADN.Model.Source{client_id: client_id, link: link, name: name} = message.source
    assert client_id == "UxUWrSdVLyCaShN62xZR5tknGvAxK93P"
    assert link == "https://app.net"
    assert name == "Test app"
  end

  test "parse channel recent message user" do
    doc = File.read!("./test/elixir_adn/parser/channels.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:channels, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Channel{} = channel1, _channel2] = ElixirADN.Parser.BaseParser.decode(:chanels, map, ElixirADN.Model.Channel)
    
    message = channel1.recent_message
    assert message.user.id == "1558"
  end

  test "parse message response" do
    doc = File.read!("./test/elixir_adn/parser/messages.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:messages, doc)
    assert result == :ok
    
    [%ElixirADN.Model.Message{} = message] = ElixirADN.Parser.BaseParser.decode(:messages, map, ElixirADN.Model.Message)
    assert message.channel_id == "1"
    assert message.created_at == "2012-12-11T00:31:49Z"
    assert message.html == "<span itemscope=\"https://app.net/schemas/Post\">Hello channel!</span>"
    assert message.id == "1"
    assert message.machine_only == false
    assert message.num_replies == 0
    assert message.text == "Hello channel!"
    assert message.thread_id == "1"
  end

  test "parse files response" do
    doc = File.read!("./test/elixir_adn/parser/files.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:files, doc)
    assert result == :ok
    
    file = ElixirADN.Parser.BaseParser.decode(:files, map, ElixirADN.Model.File)
    assert file.complete == true
    assert file.created_at == "2013-01-28T18:31:18Z"
    assert file.file_token == "auCj3h64JZrhQ9aJdmwre3KP-QL9UtWHYvt5tj_64rUJWemoIV2W8eTJv9NMaGpBFk-BbU_aWA26Q40w4jFhiPBpnIQ_lciLwfh6o8YIAQGEQziksUMxZo7gOHJ_-niw3l3MZCh7QRWzqNGpiVaUEptfKO0fETrZ8bJjDa61234a"
    assert file.id == "1"
    assert file.kind == "image"
    assert file.mime_type == "image/png"
    assert file.name == "filename.png"
    assert file.sha1 == "ef0ccae4d36d4083b53e121a6cf9cc9d7ac1234a"
    assert file.size == 172393
    assert file.total_size == 346369
    assert file.type == "com.example.test"
    assert file.url == "https://..."
    assert file.url_expires == "2013-01-25T03:00:00Z"
  end

  test "parse files derived files" do
    doc = File.read!("./test/elixir_adn/parser/files.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:files, doc)
    assert result == :ok
    
    file = ElixirADN.Parser.BaseParser.decode(:files, map, ElixirADN.Model.File)
    %ElixirADN.Model.DerivedFiles{image_thumb_200s: small, image_thumb_960r: regular} = file.derived_files
    assert small.name == "filename_image_thumb_200s.png"
    assert small.mime_type == "image/png"
    assert small.sha1 == "be91cb06d69df13bb103a359ce70cf9fba31234a"
    assert small.size == 33803
    assert small.url == "https://example.com/thumbnail_200s.png"
    assert small.url_expires == "2013-01-25T03:00:00Z"
    assert small.image_info.width == 200
    assert small.image_info.height == 200
    assert regular.name == "filename_image_thumb_960r.png"
    assert regular.mime_type == "image/png"
    assert regular.size == 140173
    assert regular.sha1 == "57004b55119002f551be5b9f2d5439dd4ad1234a"
    assert regular.url == "https://example.com/thumbnail_960r.png"
    assert regular.url_expires ==  "2013-01-25T03:00:00Z"    
    assert regular.image_info.width == 600
    assert regular.image_info.height == 800
  end

  test "parse files image info" do
    doc = File.read!("./test/elixir_adn/parser/files.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:files, doc)
    assert result == :ok
    
    file = ElixirADN.Parser.BaseParser.decode(:files, map, ElixirADN.Model.File)
    %ElixirADN.Model.ImageInfo{width: width, height: height} = file.image_info
        
    assert width == 600
    assert height == 800
  end

  test "parse files source" do
    doc = File.read!("./test/elixir_adn/parser/files.json")
    
    {result, map} = ElixirADN.Parser.BaseParser.parse(:files, doc)
    assert result == :ok
    
    file = ElixirADN.Parser.BaseParser.decode(:files, map, ElixirADN.Model.File)
    %ElixirADN.Model.Source{name: name, link: link, client_id: client_id} = file.source
        
    assert name == "Clientastic for iOS"
    assert link ==  "http://app.net"
    assert client_id == "98765zyxw"
  end

  test "parse invalid data" do
    {result, message} = ElixirADN.Parser.BaseParser.parse(:posts, 123)
    assert result == :error
    assert message == :invalid_data_to_parse
  end

end
