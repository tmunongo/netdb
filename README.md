# NetDB

## Overview

Implementing a distributed key-value store using Elixir.

## Features

- Distributed architecture allowing multiple nodes to form a cluster
- Eventual consistency for data synchronisation across nodes
- Vector clocks for handling conflicts and maintaining causal consistency
- Simple command-line interface for interacting with the store
- Automatic conflict resolution using a last-write-wins strategy

## Prerequisites

- Elixir 1.17 or later
- Erlang/OTP 25 or later

## Installation

1. Clone the repository:

   ```
   git clone https://github.com/tmunongo/netdb.git
   cd netdb
   ```

2. Fetch dependencies:

   ```
   mix deps.get
   ```

3. Compile the project:
   ```
   mix compile
   ```

## Running the Distributed Key-Value Store

1. Open three (or more) terminal windows.

2. In each terminal, start a named node:

   Terminal 1:

   ```
   iex --name node1@127.0.0.1 -S mix
   ```

   Terminal 2:

   ```
   iex --name node2@127.0.0.1 -S mix
   ```

   Terminal 3:

   ```
   iex --name node3@127.0.0.1 -S mix
   ```

3. In each terminal, connect the nodes:

   ```elixir
   Node.connect(:"node1@127.0.0.1")
   Node.connect(:"node2@127.0.0.1")
   Node.connect(:"node3@127.0.0.1")
   ```

4. Start the CLI in any of the terminals:

   ```elixir
   DistributedKVStore.CLI.main()
   ```

## Usage

Once the CLI is running, you can use the following commands:

- Put a value: `put <key> <value>`
- Get a value: `get <key>`
- Delete a value: `delete <key>`
- Quit the application: `quit`

Example:

```
> put mykey myvalue
Value stored.
> get mykey
Value: myvalue
> delete mykey
Key deleted.
> quit
Goodbye!
```

## Architecture

The system is built using Elixir's GenServer behavior, which manages the state of each node. The `DistributedKVStore` module handles the core logic, including:

- State management
- CRUD operations
- Vector clock implementation
- Periodic synchronization between nodes
- Conflict resolution

## Limitations and Future Improvements

- The current implementation uses a simple last-write-wins strategy for conflict resolution, which may not be suitable for all use cases.
- There is no persistence; data is lost when all nodes go down.
- The system has not been tested for large-scale deployments or high-concurrency scenarios.

Future improvements could include:

- Implementing more sophisticated conflict resolution strategies
- Adding persistence to disk
- Implementing a gossip protocol for more efficient data synchronization
- Adding comprehensive logging and monitoring
- Implementing sharding for improved scalability

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Inspired by the principles discussed in "Designing Data-Intensive Applications" by Martin Kleppmann
- Built with Elixir and OTP
