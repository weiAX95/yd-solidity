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
  const yidengNFT = await YidengNFT.deploy();
  await yidengNFT.waitForDeployment();
  // 等待合约部署完成
  // await YidengNFT.deployed();
  console.log("YidengNFT deployed to:", await yidengNFT.getAddress());

  // 部署学习挖矿DAO合约
  // const CourseLearningReward = await hre.ethers.getContractFactory("CourseLearningReward");
  // const courseLearningReward = await CourseLearningReward.deploy(
  //   yidengToken.target,     // 奖励代币地址
  //   ethers.parseUnits("0.01", 18),  // 每秒0.001个代币
  //   5                        // 质量系数
  // );
  // await courseLearningReward.waitForDeployment();
  // console.log("CourseLearningReward deployed to:", courseLearningReward.target);

  return { yidengToken, daoContract, yidengNFT };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});