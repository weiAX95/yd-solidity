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

  return { yidengToken, daoContract };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});