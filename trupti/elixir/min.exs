Mix.install([
  {:httpoison, "~> 1.8"},
  {:jason, "~> 1.2"}
])

Code.require_file("lib/api.ex", __DIR__)

{cookie, id} = API.register()
:timer.sleep(1000)

API.create(cookie, id)
:timer.sleep(5000)

API.guess(cookie, id)
