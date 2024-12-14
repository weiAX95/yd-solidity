const hre = require("hardhat");

async function main() {
  // 部署 YidengToken
  const YidengToken = await hre.ethers.getContractFactory("YidengToken");
  const initialSupply = 1000000; // 100万初始供应量
  const yidengToken = await YidengToken.deploy(initialSupply);
  await yidengToken.waitForDeployment();

  console.log("YidengToken deployed to:", await yidengToken.getAddress());

  // 部署 DAOContract
  const DAOContract = await hre.ethers.getContractFactory("DAOContract");
  const daoContract = await DAOContract.deploy(await yidengToken.getAddress());
  await daoContract.waitForDeployment();

  console.log("DAOContract deployed to:", await daoContract.getAddress());

  // 部署YiDengNFT
  // 获取合约工厂
  const YidengNFT = await hre.ethers.getContractFactory("YidengNFT");
  // 部署合约
  const YidengNFT = await YidengNFT.deploy(await yidengToken.getAddress());
  await daoContract.waitForDeployment();
  // 等待合约部署完成
  await YidengNFT.deployed();
  console.log("YidengNFT deployed to:", YidengNFT.address);

  return { yidengToken, daoContract, YidengNFT };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});