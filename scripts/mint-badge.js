const hre = require("hardhat");

async function main() {
  // 获取签名者（默认使用第一个账户）
  const [deployer] = await hre.ethers.getSigners();
  
  // 获取已部署的合约
  const YidengNFT = await hre.ethers.getContractFactory("YidengNFT");
  const YidengNFT = await YidengNFT.attach("YOUR_DEPLOYED_CONTRACT_ADDRESS");
  
  // 为特定学生铸造徽章
  const studentAddress = "0x1234..."; // 替换为实际学生地址
  
  const tx = await YidengNFT.mintBadge(
    studentAddress, 
    "区块链基础课程", 
    "张三", 
    40
  );
  
  // 等待交易确认
  await tx.wait();
  
  console.log(`徽章已铸造给 ${studentAddress}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });