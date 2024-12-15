const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);

  // 部署治理代币
  const Token = await ethers.getContractFactory('YidengToken');
  const token = await Token.deploy('Yideng Governance Token', 'YID');
  console.log('Governance Token deployed to:', token.address);

  // 部署DAO合约
  const DAO = await ethers.getContractFactory('DAOContract');
  const dao = await DAO.deploy(token.address); // 将治理代币地址传给DAO合约
  console.log('DAO Contract deployed to:', dao.address);

  // 获取部署者账户
  const [owner, voter] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', owner.address);

  // 合约地址（假设已部署）
  const daoContractAddress = '你的DAO合约地址';
  const yidengTokenAddress = '你的治理代币地址';

  // 获取已部署的DAO合约
  const DAOContract = await ethers.getContractFactory('DAOContract');
  const daoContract = DAOContract.attach(daoContractAddress);

  // 查看合约所有者
  const currentOwner = await daoContract.owner();
  console.log('DAO当前所有者:', currentOwner);

  // 创建一个新提案
  console.log('创建提案...');
  const description = '这是一个新的提案！';
  const tx = await daoContract.createProposal(description);
  const receipt = await tx.wait();
  const proposalId = receipt.events[0].args.proposalId;
  console.log(`提案已创建，ID: ${proposalId}`);

  // 计算投票权
  const voterVotingPower = await daoContract.calculateVotingPower(voter.address);
  console.log(`投票者 ${voter.address} 的投票权: ${voterVotingPower}`);

  // 为提案投票
  console.log('投票...');
  const voteTx = await daoContract.connect(voter).vote(proposalId, true); // true表示赞成
  await voteTx.wait();
  console.log(`投票完成！`);

  // 获取提案统计信息
  const stats = await daoContract.getVoteStats(proposalId);
  console.log(
    `提案统计 - 赞成票: ${stats[0]}, 反对票: ${stats[1]}, 总票数: ${stats[2]}, 是否通过: ${stats[3]}`
  );
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
