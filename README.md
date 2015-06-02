ElixirADN
=========

A library to interact with ADN.  Still in it's infancy, it only supports limited
endpoints.  

#Endpoints
## Channel
###Create a message
Creates a message that says "hi"
```elixir
%ElixirADN.Model.Message{text: "hi"}
  |> ElixirADN.Endpoints.Channel.create_message("user_token")
```

###Respond to a message 'original_message' with "hi"
```elixir
%ElixirADN.Model.Response{text: "hi"}
  |> ElixirADN.Helpers.ResponseHelper.resond(original_message, "user_token")
```

##Filter
###Get all
Get every filter a user has created
```elixir
ElixirADN.Endpoints.Filter.get("user_token")
```

###Get a filter
Get a specific filter a user has created by id
```elixir
ElixirADN.Endpoints.Filter.get("filter_id", "user_token")
```
###Create
Create a filter to show all posts by the client Dragoon
```elixir
clause = %ElixirADN.Model.Clause{field: "/data/source/client_id", 
object_type: "post", operator: "matches", 
value: "KEWBRxq3j5fGvMZ52VPnZKvhxxZHVyZE"}

%ElixirADN.Model.Filter{clauses: [clause], 
match_policy: "include_any", name: "DragoonClient"}
  |> Filter.create_filter("user_token")
```

##Global
###Create a post 
Create a post or reply
```elixir
%ElixirADN.Model.Post{text: "hi"}
  |> ElixirADN.Endpoints.Post.create_post("user_token")
```

###Get global posts
Returns 20 posts from global
```elixir
{:ok, posts } = ElixirADN.Endpoints.Post.get_posts(
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})
```

##User

###Get
Gets a user by name or id
```elixir
{:ok, user } = ElixirADN.Endpoints.User.get("@username", 
%ElixirADN.Endpoints.Parameters.UserParameters{}
```

###User Posts 
Get the posts for a user
```elixir
{:ok, posts } = ElixirADN.Endpoints.User.get_posts("@username", 
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})
```
##User Mentions 
Get the posts mentioning a user
```elixir
{:ok, posts } = ElixirADN.Endpoints.User.get_mentions("@username", 
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{}, 
user_token)
```

#Streams
##App Streams
App streams are regular elixir streams that monitor ADN with filters.  
To create an app stream you need an app token and some parameters.  This
example will read 1 dragoon post from ADN:
```elixir
%ElixirADN.Endpoints.Parameters.AppStreamParameters{
  object_types: ["post"],
  type: "long_poll",
  filter_id: [whatever filter_id you created in the Create Filter example above],
  key: "dragoon_stream_test"
}
  |> ElixirADN.Endpoints.AppStream.stream("app_token")
  |> Enum.take(1)
```

##User Streams
User streams are a way to stream ADN endpoints without having to constantly 
spam them for updates.  Unlike app streams, user streams require a user token.
Since there are many endpoints to stream, 1 stream can handle multiple endpoints.
This is done through subscriptions.  Take a look at ElixirADN.Endpoints.Subscription
to see all the possibilities.  Here is quick example to stream a users mentions:
```elixir
stream_params = %ElixirADN.Endpoints.Parameters.StreamEndpointParameters{}
subscription_params = %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}
ElixirADN.Endpoints.UserStream.stream(:mentions_stream_id, 
  stream_parameters,[{:my_mentions, subscription_parameters}], "user_token")
  |> Enum.take(1)
```
A stream can only have 1 StreamEndpointParameters, but each subscription can
have it's own SubscriptionParameters.  

#Bot Behaviour
A way to create bots that listen to user streams and can act on them.  To create a bot use the Bot behaviour like below (or read the [bot.me document](bot.md) for more info):

```elixir
defmodule ExampleBot do
  @behaviour ElixirADN.Behaviours.Bot
```

The behaviour requires implementation of:

```elixir
on_post_mention(%ElixirADN.Model.Post{})
on_message_mention(%ElixirADN.Model.Message{})
```

This function should define what happens when a post or message mentions the bot.

To start the bot, make the following call. 

```elixir
ElixirADN.Behaviours.Bot.start_bot(ExampleBot, "@username", "auth_token", %ElixirADN.Endpoints.Parameters.StreamEndpointParameters{}, [{:my_mentions, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}}])
```

The parameters are the bot module name, the bots username, the auth token 
associated with the account, the parameters to use when creating the user stream, and a list of subscriptions the stream should subscribe to.
