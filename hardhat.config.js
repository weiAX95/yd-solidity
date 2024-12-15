require('@nomicfoundation/hardhat-toolbox');
// import { HardhatUserConfig } from 'hardhat/config';
// require('@nomiclabs/hardhat-ethers');
require('hardhat-abi-exporter');
require('@typechain/hardhat');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: '0.8.20',
  // abiExporter: {
  //   path: __dirname + '/frontend/src/abi', // 将生成的 ABI 文件存放在前端项目的 src/abi 文件夹下
  //   clear: true, // 在生成新的 ABI 文件之前清除旧的
  //   flat: true, // 不创建按合约名分隔的子目录
  //   only: [], // 导出所有合约abiExporter
  //   spacing: 2, // 格式化为 2 个空格的缩进
  //   pretty: true, // 使 JSON 格式更具可读性
  // },
  // typechain: {
  //   outDir: __dirname + '/frontend/src/types', // 将生成的 TypeScript 类型文件存放在前端项目的 src/types 文件夹下
  //   target: 'ethers-v5', // 使用 Ethers.js v5 类型
  // },
  networks: {
    // 本地开发网络
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    // 可以添加其他网络配置，如 goerli, sepolia 等
  },
};
