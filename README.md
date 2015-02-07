ElixirADN
=========

A library to interact with ADN.  Still in it's infancy, it only supports limited
endpoints.  

#Endpoints
## User Posts: Get the posts for a user
{:ok, posts }= ElixirADN.Endpoints.User.get_posts("@username", 
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})

## User Mentions: Get the posts mentioning a user
{:ok, posts }= ElixirADN.Endpoints.User.get_mentions("@username", "auth_token",
%ElixirADN.Endpoints.Parameters.PostParameters{},
%ElixirADN.Endpoints.Parameters.Pagination{})

## Create a post: Create a post or reply
post = %ElixirADN.Model.Post{text: "hi"}
ElixirADN.Endpoints.Post.create_post("auth_token", post)

#Bot Behaviour
A way to create bots that listen for post mentions and can act on them.  To create a bot use the Bot behaviour like below:

defmodule ExampleBot do
	@behaviour ElixirADN.Behaviours.Bot	

The behaviour requires implementation of:

on_post_mention(%ElixirADN.Model.Post{} = post)

This function should define what happens when a post mentions the bot.

Finally, somewhere in the initialization process, make the following call. 

ElixirADN.Behaviours.Bot.start_bot(ExampleBot, "@username", "auth_token", last_post_id, 5)

The parameters are the bot module name, the bots username, the auth token 
associated with the account, the post id to start looking for mentions,
and the interval in seconds to check for mentions.

