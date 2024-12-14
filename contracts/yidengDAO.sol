// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; // 注意这里的路径变化

contract DAOContract is Ownable, ReentrancyGuard {
    // 治理代币接口
    IERC20 public yidengToken;

    struct Proposal {
        uint256 id; // 提案ID
        string description; // 提案描述
        uint256 forVotes; // 赞成票
        uint256 againstVotes; // 反对票
        uint256 startTime; // 开始时间
        uint256 endTime; // 结束时间
        bool executed; // 是否已执行
        mapping(address => bool) hasVoted; // 投票记录
        mapping(address => uint256) voteCount; // 每个地址的投票数
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    // 投票规则常量
    uint256 public constant BASE_VOTES = 1; // 基础票数
    uint256 public constant TOKENS_PER_VOTE = 10; // 每10个代币增加1票
    uint256 public constant VOTE_THRESHOLD = 60; // 60% 通过阈值
    uint256 public constant VOTING_PERIOD = 7 days; // 投票周期

    //  提案创建事件
    event ProposalCreated(uint256 indexed proposalId, string description);
    //  投票事件
    event Voted(
        uint256 indexed proposalId,
        address indexed voter,
        uint256 votes
    );
    // 提案执行事件
    event ProposalExecuted(uint256 indexed proposalId);

    constructor(address _yidengToken) Ownable(msg.sender) {
        // 初始化治理代币接口
        yidengToken = IERC20(_yidengToken);
    }

    // 创建提案
    function createProposal(
        string memory _description // 提案描述
    ) external returns (uint256) {
        // 提案ID
        uint256 proposalId = proposalCount++;
        // 创建提案
        Proposal storage proposal = proposals[proposalId];

        // 初始化提案数据
        proposal.id = proposalId;
        // 提案描述
        proposal.description = _description;
        // 提案开始时间
        proposal.startTime = block.timestamp;
        // 提案结束时间
        proposal.endTime = block.timestamp + VOTING_PERIOD;

        // 触发提案创建事件
        emit ProposalCreated(proposalId, _description);
        return proposalId;
    }

    // 计算投票权
    function calculateVotingPower(address voter) public view returns (uint256) {
        // 获取用户代币余额
        uint256 tokenBalance = yidengToken.balanceOf(voter);
        // 计算投票权
        uint256 additionalVotes = tokenBalance / (TOKENS_PER_VOTE * 10 ** 18);
        // 返回投票权
        return BASE_VOTES + additionalVotes;
    }

    // 投票
    function vote(uint256 _proposalId, bool _support) external nonReentrant {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.executed, "Proposal executed");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 votingPower = calculateVotingPower(msg.sender);
        require(votingPower > 0, "No voting power");

        proposal.hasVoted[msg.sender] = true;
        proposal.voteCount[msg.sender] = votingPower;

        if (_support) {
            proposal.forVotes += votingPower;
        } else {
            proposal.againstVotes += votingPower;
        }

        emit Voted(_proposalId, msg.sender, votingPower);
    }

    // 检查提案是否通过
    function isProposalPassed(uint256 _proposalId) public view returns (bool) {
        Proposal storage proposal = proposals[_proposalId];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        if (totalVotes == 0) return false;

        uint256 forPercentage = (proposal.forVotes * 100) / totalVotes;
        return forPercentage > VOTE_THRESHOLD;
    }

    // 执行提案
    function executeProposal(
        uint256 _proposalId
    ) external nonReentrant onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(isProposalPassed(_proposalId), "Proposal not passed");

        proposal.executed = true;
        //
        emit ProposalExecuted(_proposalId);

        // 在这里实现具体的提案执行逻辑
    }

    // 获取投票统计
    function getVoteStats(
        uint256 _proposalId
    )
        external
        view
        returns (
            uint256 forVotes,
            uint256 againstVotes,
            uint256 totalVotes,
            bool isPassed
        )
    {
        Proposal storage proposal = proposals[_proposalId];
        totalVotes = proposal.forVotes + proposal.againstVotes;
        return (
            proposal.forVotes,
            proposal.againstVotes,
            totalVotes,
            isProposalPassed(_proposalId)
        );
    }
}
