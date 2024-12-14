require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    // 本地开发网络
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // 可以添加其他网络配置，如 goerli, sepolia 等
  }
};
