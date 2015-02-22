ElixirADN
=========

A library to interact with ADN.  Still in it's infancy, it only supports limited
endpoints.  

#Endpoints
## User Posts 
Get the posts for a user
```elixir
{:ok, posts } = ElixirADN.Endpoints.User.get_posts("@username", 
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})
```
## User Mentions 
Get the posts mentioning a user
```elixir
{:ok, posts } = ElixirADN.Endpoints.User.get_mentions("@username", "auth_token",
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})
```

## Create a post 
Create a post or reply
```elixir
post = %ElixirADN.Model.Post{text: "hi"}
ElixirADN.Endpoints.Post.create_post("auth_token", post)
```
#Bot Behaviour
A way to create bots that listen for post mentions and can act on them.  To create a bot use the Bot behaviour like below:

```elixir
defmodule ExampleBot do
	@behaviour ElixirADN.Behaviours.Bot
```

The behaviour requires implementation of:

```elixir
on_post_mention(%ElixirADN.Model.Post{} = post)
on_message_mention(%ElixirADN.Model.Message{} = message)
```

This function should define what happens when a post or message mentions the bot.

To start the bot, make the following call. 

```elixir
ElixirADN.Behaviours.Bot.start_bot(ExampleBot, "@username", "auth_token", %ElixirADN.Endpoints.Parameters.StreamEndpointParameters{}, [{:my_mentions, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}}])
```

The parameters are the bot module name, the bots username, the auth token 
associated with the account, the parameters to use when creating the user stream and a list of subscriptions the stream should subscribe to.