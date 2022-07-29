require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.1",
  // add whatever networks you would like!
  networks: {
    hardhat: {},
    /* rinkeby: {
      url: process.env.RINKEBY_API_KEY,
      accounts: process.env.PRIVATE_KEY,
    },
    mainnet: {
      url: process.env.MAINNET_API_KEY,
      accounts: process.env.PRIVATE_KEY,
    }, */
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
