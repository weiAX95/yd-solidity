const hre = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);

  // 1. 部署 YidengToken
  const YidengToken = await ethers.getContractFactory('YidengToken');
  const yidengToken = await YidengToken.deploy();
  await yidengToken.waitForDeployment();
  const tokenAddress = await yidengToken.getAddress();
  console.log('YidengToken deployed to:', tokenAddress);

  // 初始化 YidengToken
  const teamWallet = deployer.address; // 使用部署者地址作为团队钱包
  const marketingWallet = deployer.address; // 示例地址，实际使用时需要修改
  const communityWallet = deployer.address; // 示例地址，实际使用时需要修改

  await yidengToken.initialize(teamWallet, marketingWallet, communityWallet);
  console.log('YidengToken initialized');

  // 2. 部署 DAOContract
  const DAOContract = await ethers.getContractFactory('DAOContract');
  const daoContract = await DAOContract.deploy(tokenAddress);
  await daoContract.waitForDeployment();
  console.log('DAOContract deployed to:', await daoContract.getAddress());

  // 3. 部署 CourseMarket
  const CourseMarket = await ethers.getContractFactory('CourseMarket');
  const courseMarket = await CourseMarket.deploy();
  await courseMarket.waitForDeployment();
  console.log('CourseMarket deployed to:', await courseMarket.getAddress());

  // 4. 部署 ArtNFT
  const ArtNFT = await ethers.getContractFactory('ArtNFT');
  const artNFT = await ArtNFT.deploy(
    'Yideng NFT', // name
    'YDNFT', // symbol
    'https://api.yideng.com/nft/' // baseURI
  );
  await artNFT.waitForDeployment();
  console.log('ArtNFT deployed to:', await artNFT.getAddress());

  // 打印所有合约地址
  console.log('\nContract Addresses:');
  console.log('====================');
  console.log('YidengToken:', tokenAddress);
  console.log('DAOContract:', await daoContract.getAddress());
  console.log('CourseMarket:', await courseMarket.getAddress());
  console.log('ArtNFT:', await artNFT.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
