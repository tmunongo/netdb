defmodule Netdb.CLI do
  def main do
    IO.puts("Welcome to NetKV - a distributed key-value store")
    IO.puts("Available commands: put, get, delete, quit")
    IO.puts("Format: <command> <key> <value>")
    IO.puts("Example: put mykey myvalue")

    loop()
  end

  defp loop do
    IO.gets("> ")
    |> String.trim()
    |> String.split()
    |> execute()

    loop()
  end

  defp execute(["put", key, value]) do
    Netdb.put(Netdb, key, value)
    IO.puts("value stored.")
  end

  defp execute(["get", key]) do
    case Netdb.get(Netdb, key) do
      nil -> IO.puts("Key not found")
      value -> IO.puts("Value: #{value}")
    end
  end

  defp execute(["delete", key]) do
    Netdb.delete(Netdb, key)
    IO.puts("Key deleted.")
  end

  defp execute(["quit"]) do
    IO.puts("Ciao ciao!")
    System.halt(0)
  end

  defp execute([_]) do
    IO.puts("Invalid command. Try again :)")
  end
end
