module.exports = {
  networks: {
    testrpc: {
      network_id: "*",
      host: "localhost",
      port: 8545,
      gas: 4612388
    },
    rinkeby: {
      network_id: 4,
      host: "localhost",
      port: 8545,
      from: "0x9A48095A20c98113D04849010a04E4b41d54e04a",
    }
  }
};
