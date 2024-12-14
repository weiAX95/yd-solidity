const hre = require("hardhat");

async function main() {
  // 获取部署的合约地址
  const YidengToken = await hre.ethers.getContractFactory("YidengToken");
  const DAOContract = await hre.ethers.getContractFactory("DAOContract");
  
  const yidengToken = YidengToken.attach("YOUR_TOKEN_CONTRACT_ADDRESS");
  const daoContract = DAOContract.attach("YOUR_DAO_CONTRACT_ADDRESS");

  // 获取签名者
  const [owner, addr1] = await hre.ethers.getSigners();

  // 调用合约函数示例
  
  // 1. 铸造代币
  console.log("Minting tokens...");
  const mintTx = await yidengToken.mint(addr1.address, ethers.parseEther("100"));
  await mintTx.wait();
  console.log("Minted 100 tokens to:", addr1.address);

  // 2. 查看余额
  const balance = await yidengToken.balanceOf(addr1.address);
  console.log("Balance:", ethers.formatEther(balance));

  // 3. 创建提案
  console.log("Creating proposal...");
  const createProposalTx = await daoContract.createProposal("Test Proposal");
  await createProposalTx.wait();
  console.log("Proposal created");

  // 4. 投票
  console.log("Voting...");
  const voteTx = await daoContract.vote(0, true);
  await voteTx.wait();
  console.log("Voted");

  // 5. 查看提案状态
  const stats = await daoContract.getVoteStats(0);
  console.log("Proposal stats:", stats);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});