# MixScript

Allows you to use mix packages in an elixir script.

## Example

Let us say, you have a file at `~/scripts/elixir_curl.exs`

```elixir
mix_dep {:httpotion, ">0.0.0"}

if args == [] do
  IO.puts "invalid args"
else
  IO.inspect HTTPotion.get(hd args)
end
```

You can run the following:

```
# compile our elixir script
mix_script compile ~/scripts/elixir_curl.exs
# run it with args
~/scripts/elixir_curl http://google.com
> %HTTPotion.Response{body: "<HTML><HEAD><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">\n<TITLE>302 Moved</TITLE></HEAD><BODY>\n<H1>302 Moved</H1>\nThe document has moved\n<A HREF=\"http://www.google.co.in/?gfe_rd=cr&amp;ei=DBAaWbWTLurx8AeKp4uwCg\">here</A>.\r\n</BODY></HTML>\r\n",
 headers: %HTTPotion.Headers{hdrs: %{"cache-control" => "private",
    "content-length" => "261", "content-type" => "text/html; charset=UTF-8",
    "date" => "Mon, 15 May 2017 20:31:08 GMT",
    "location" => "http://www.google.co.in/?gfe_rd=cr&ei=DBAaWbWTLurx8AeKp4uwCg",
    "referrer-policy" => "no-referrer"}}, status_code: 302}
```

## Installation

```
git clone https://github.com/minhajuddin/mix_script
cd mix_script
mix escript.build
# this will generate the ./mix_script binary
```

## TODO
  [  ] Make this more efficient by using a common directory for the mix packages
  [  ] Make it usable via a shebang `#!/usr/bin/env mix_script` which does compilation and execution
