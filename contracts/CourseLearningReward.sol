// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CourseLearningReward is Ownable {
    // 学习记录结构体
    struct LearningRecord {
        address student;
        string courseHash; // IPFS哈希，存储课程信息
        uint256 videoDuration; // 视频时长（秒）
        string summaryHash; // 总结文章的IPFS哈希
        uint256 rewardAmount; // 奖励金额
        bool isRewarded; // 是否已发放奖励
    }

    // 奖励代币
    IERC20 public rewardToken;

    // 学习记录映射
    mapping(bytes32 => LearningRecord) public learningRecords;

    // 奖励配置
    uint256 public baseRewardPerSecond; // 每秒视频的基础奖励
    uint256 public summaryQualityMultiplier; // 总结质量奖励系数

    // 事件
    event LearningRecordSubmitted(
        bytes32 recordId,
        address student,
        string courseHash,
        uint256 videoDuration
    );

    event RewardClaimed(
        bytes32 recordId,
        address student,
        uint256 rewardAmount
    );

    constructor(
        address _rewardTokenAddress,
        uint256 _baseRewardPerSecond,
        uint256 _summaryQualityMultiplier
    ) Ownable(msg.sender) {
        rewardToken = IERC20(_rewardTokenAddress);
        baseRewardPerSecond = _baseRewardPerSecond;
        summaryQualityMultiplier = _summaryQualityMultiplier;
    }

    // 学生提交学习记录
    function submitLearningRecord(
        string memory courseHash,
        uint256 videoDuration,
        string memory summaryHash
    ) public {
        require(videoDuration > 0, "Invalid video duration");

        bytes32 recordId = keccak256(
            abi.encodePacked(msg.sender, courseHash, summaryHash)
        );

        learningRecords[recordId] = LearningRecord({
            student: msg.sender,
            courseHash: courseHash,
            videoDuration: videoDuration,
            summaryHash: summaryHash,
            rewardAmount: 0,
            isRewarded: false
        });

        emit LearningRecordSubmitted(
            recordId,
            msg.sender,
            courseHash,
            videoDuration
        );
    }

    // DAO手动发放奖励
    function claimReward(
        bytes32 recordId,
        uint256 qualityScore // DAO对总结质量的评分
    ) public onlyOwner {
        LearningRecord storage record = learningRecords[recordId];

        require(!record.isRewarded, "Reward already claimed");
        require(record.student != address(0), "Invalid record");

        // 计算奖励：基础奖励 * 视频时长 * 质量系数
        uint256 baseReward = record.videoDuration * baseRewardPerSecond;
        uint256 finalReward = (baseReward *
            (summaryQualityMultiplier + qualityScore)) / 10;

        // 发放奖励
        require(
            rewardToken.transfer(record.student, finalReward),
            "Reward transfer failed"
        );

        record.rewardAmount = finalReward;
        record.isRewarded = true;

        emit RewardClaimed(recordId, record.student, finalReward);
    }

    // 更新奖励参数（仅所有者）
    function updateRewardParameters(
        uint256 _baseRewardPerSecond,
        uint256 _summaryQualityMultiplier
    ) public onlyOwner {
        baseRewardPerSecond = _baseRewardPerSecond;
        summaryQualityMultiplier = _summaryQualityMultiplier;
    }

    // 提取合约中剩余的奖励代币
    function withdrawRemainingTokens() public onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(owner(), balance);
    }
}
