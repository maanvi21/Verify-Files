module.exports = {
  networks: {
    // Connect to Ganache running on localhost:7545 (GUI) or 8545 (CLI)
    development: {
      host: "127.0.0.1",
      port: 7545,       // Change to 8545 if using ganache-cli
      network_id: "*",  // Match any network id
    },
  },

  // Solidity compiler configuration
  compilers: {
    solc: {
      version: "0.8.19",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
