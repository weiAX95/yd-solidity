// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

contract DAOContract is Ownable, ReentrancyGuard {
  // 治理代币接口
  IERC20 public yidengToken;

  // 提案结构体
  struct Proposal {
    uint256 id; // 提案ID
    string description; // 提案描述
    uint256 forVotes; // 赞成票
    uint256 againstVotes; // 反对票
    uint256 startTime; // 提案开始时间
    uint256 endTime; // 提案结束时间
    bool executed; // 是否执行
    mapping(address => bool) hasVoted; // 投票记录
  }

  uint256 public proposalCount;
  mapping(uint256 => Proposal) public proposals;

  // 投票规则常量
  uint256 public constant BASE_VOTES = 1; // 基础票数
  uint256 public constant TOKENS_PER_VOTE = 10; // 每10个代币增加1票
  uint256 public constant VOTE_THRESHOLD = 60; // 通过比例阈值（60%）
  uint256 public constant VOTING_PERIOD = 7 days; // 投票周期

  // 事件
  event ProposalCreated(uint256 indexed proposalId, string description);
  event Voted(uint256 indexed proposalId, address indexed voter, uint256 votes);
  event ProposalExecuted(uint256 indexed proposalId);

  // 构造函数，初始化初始所有者和治理代币
  constructor(address _owner, address _yidengToken) Ownable(_owner) {
    yidengToken = IERC20(_yidengToken);
  }

  // 创建提案
  function createProposal(string memory _description) external onlyOwner returns (uint256) {
    uint256 proposalId = proposalCount++;
    Proposal storage proposal = proposals[proposalId];

    proposal.id = proposalId;
    proposal.description = _description;
    proposal.startTime = block.timestamp;
    proposal.endTime = block.timestamp + VOTING_PERIOD;

    emit ProposalCreated(proposalId, _description);
    return proposalId;
  }

  // 计算用户的投票权（基于代币余额）
  function calculateVotingPower(address voter) public view returns (uint256) {
    uint256 tokenBalance = yidengToken.balanceOf(voter);
    uint256 additionalVotes = tokenBalance / (TOKENS_PER_VOTE * 10 ** 18);
    return BASE_VOTES + additionalVotes;
  }

  // 投票函数
  function vote(uint256 _proposalId, bool _support) external nonReentrant {
    Proposal storage proposal = proposals[_proposalId];
    require(block.timestamp <= proposal.endTime, 'Voting period has ended');
    require(!proposal.executed, 'Proposal has already been executed');
    require(!proposal.hasVoted[msg.sender], 'You have already voted');

    uint256 votingPower = calculateVotingPower(msg.sender);
    require(votingPower > 0, 'You have no voting power');

    proposal.hasVoted[msg.sender] = true;

    if (_support) {
      proposal.forVotes += votingPower;
    } else {
      proposal.againstVotes += votingPower;
    }

    emit Voted(_proposalId, msg.sender, votingPower);
  }

  // 检查提案是否通过（60%的通过比例）
  function isProposalPassed(uint256 _proposalId) public view returns (bool) {
    Proposal storage proposal = proposals[_proposalId];
    uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
    if (totalVotes == 0) return false;

    uint256 forPercentage = (proposal.forVotes * 100) / totalVotes;
    return forPercentage >= VOTE_THRESHOLD;
  }

  // 执行提案
  function executeProposal(uint256 _proposalId) external nonReentrant onlyOwner {
    Proposal storage proposal = proposals[_proposalId];
    require(block.timestamp > proposal.endTime, 'Voting period is still active');
    require(!proposal.executed, 'Proposal has already been executed');
    require(isProposalPassed(_proposalId), 'Proposal did not pass');

    proposal.executed = true;

    // 触发执行事件
    emit ProposalExecuted(_proposalId);

    // 在这里添加实际的提案执行逻辑
  }

  // 获取提案的投票统计
  function getVoteStats(
    uint256 _proposalId
  )
    external
    view
    returns (uint256 forVotes, uint256 againstVotes, uint256 totalVotes, bool isPassed)
  {
    Proposal storage proposal = proposals[_proposalId];
    totalVotes = proposal.forVotes + proposal.againstVotes;
    return (proposal.forVotes, proposal.againstVotes, totalVotes, isProposalPassed(_proposalId));
  }
}
