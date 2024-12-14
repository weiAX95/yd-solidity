# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```

# 编译合约
npx hardhat compile

# 运行本地节点
npx hardhat node

# 在本地节点部署
npx hardhat run scripts/deploy.js --network localhost

# 运行测试
npx hardhat test

# 铸造徽章
npx hardhat run scripts/mint-badge.js --network localhost