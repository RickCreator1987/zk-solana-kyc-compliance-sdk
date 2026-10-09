// Wallet connection (simplified).
module Wallet = {
  type wallet = {publicKey: string}
  let connect = () => {
    // Mock connection.
    {publicKey: "mock-public-key"}
  }
}