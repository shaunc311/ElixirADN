An example bot
=========

Here is an example bot that you can use to structure your own bot after:
```elixir
defmodule MagicEightBallBot do
  @behaviour ElixirADN.Behaviours.Bot	

  #Define what happens when a user mentions the bot
  def on_post_mention(%ElixirADN.Model.Post{} = post) do
    respond_to_post(post)
    :ok
  end

  #This would be the same as on_post_mention if you also
  #added channel subscriptions
  def on_message_mention(%ElixirADN.Model.Message{}) do
    :ok
  end

  defp respond_to_post(post) do
    #Create a post to respond to the user with
  	post = get_magic_response
  	  |> prepend_user(post)
  	  |> create_post(post)
  	
  	#I typically store the auth token in an agent but you can do whatever
  	ElixirADN.Endpoints.Post.create_post("auth_token", post)
  end

  #Use a combination of magic and science to get the correct
  #response for the given question
  defp get_magic_response() do
  	["It is certain", "It is decidedly so", "Without a doubt",
  	"Yes definitely", "You may rely on it", "As I see it, yes",
  	"Most likely", "Outlook good", "Yes", "Signs point to yes",
  	"Reply hazy try again", "Ask again later", 
  	"Better not tell you now", "Cannot predict now",
  	"Concentrate and ask again", "Don't count on it", 
  	"My reply is no", "My sources say no", "Outlook not so good",
  	"Very doubtful"]
  	  |> Enum.shuffle
  	  |> List.first
  end

  #Add the mention to the beginning of the response
  defp prepend_user(response, post) do
  	"@" <> post.user.username <> " " <> response
  end

  #Create a post to respond to the initial post
  defp create_post(response, post) do
  	ElixirADN.Model.Post{ text: response, reply_to: post.id}
  end
end
```

Once you create the bot, you start it like this:
```elixir
  iex> ElixirADN.Behaviours.Bot.start_bot(MagicEightBallBot, "@magiceightball", "auth_token", %ElixirADN.Endpoints.Parameters.StreamEndpointParameters{}, [{:my_mentions, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}}])
```

That's blocking so it's probably better to spawn it like so:
```elixir
  iex> spawn fn -> ElixirADN.Behaviours.Bot.start_bot(MagicEightBallBot, "@magiceightball", "auth_token", %ElixirADN.Endpoints.Parameters.StreamEndpointParameters{}, [{:my_mentions, %ElixirADN.Endpoints.Parameters.SubscriptionParameters{}}]) end
```

ElixirADN.Endpoints.Subscription shows all the endpoints you can subscribe to.