require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.1",
  // add whatever networks you would like!
  networks: {
    hardhat: {},
    rinkeby: {
      url: process.env.QUICKNODE_API_KEY_URL,
      accounts: [process.env.CURVE_PRIVATE_KEY]
    },
    /*mainnet: {
      url: process.env.MAINNET_API_KEY,
      accounts: process.env.PRIVATE_KEY,
    }, */
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
