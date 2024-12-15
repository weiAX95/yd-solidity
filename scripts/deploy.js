const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  // 部署 YidengToken
  const YidengToken = await hre.ethers.getContractFactory('YidengToken');
  const yidengToken = await YidengToken.deploy(); // No need to pass initialSupply here
  await yidengToken.waitForDeployment();

  console.log('YidengToken deployed to:', await yidengToken.getAddress());

  // 初始化代币分配 (调用 initialize 函数)
  // const teamWallet = '0xTeamWalletAddress'; // Replace with actual address
  // const marketingWallet = '0xMarketingWalletAddress'; // Replace with actual address
  // const communityWallet = '0xCommunityWalletAddress'; // Replace with actual address

  // const tx = await yidengToken.initialize(teamWallet, marketingWallet, communityWallet);
  // await tx.wait();

  const DAOContract = await hre.ethers.getContractFactory('DAOContract');
  const daoContract = await DAOContract.deploy(deployer.address, await yidengToken.getAddress());

  // console.log('DAO Contract deployed to:', daoContract.address);

  console.log('YidengToken initialized with token distribution');

  // // 部署 DAOContract
  // const DAOContract = await hre.ethers.getContractFactory('DAOContract');
  // const daoContract = await DAOContract.deploy(await yidengToken.getAddress()); // Pass token address
  // await daoContract.waitForDeployment();

  // console.log('DAOContract deployed to:', await daoContract.getAddress());

  // 部署 YiDengNFT
  const YidengNFT = await hre.ethers.getContractFactory('YidengNFT');
  const yidengNFT = await YidengNFT.deploy();
  await yidengNFT.waitForDeployment();
  console.log('YidengNFT deployed to:', await yidengNFT.getAddress());

  return { yidengToken, daoContract, yidengNFT };
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
