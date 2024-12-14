// 核心特性
// 不可转让的 ERC721 徽章
// 每个学生只能获得一个徽章
// 只有合约拥有者可以铸造徽章
// 元数据字段
// 课程名称
// 完成日期
// 讲师名称
// 课程学习时长
// 主要函数
// mintBadge(): 为学生铸造徽章
// getBadgeMetadata(): 查询徽章元数据
// hasStudentReceivedBadge(): 检查学生是否已获得徽章
// totalBadgesMinted(): 获取已铸造徽章总数
// 特殊设计
// 重写 transferFrom 和 safeTransferFrom 方法，使 NFT 不可转让
// 通过 _hasReceivedBadge 映射确保每个地址只能获得一个徽章
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 导入 OpenZeppelin 的 ERC721 标准合约
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// 导入权限控制合约
import "@openzeppelin/contracts/access/Ownable.sol";
// 导入计数器工具
// import "@openzeppelin/contracts/utils/Counters.sol";

contract YidengNFT is ERC721, Ownable {
    // 使用 Counters 库来管理 Token ID
    // using Counters for Counters.Counter;
    // Counters.Counter private _tokenIds;
    uint256 private _tokenIds = 0;

    function _incrementTokenIds() private returns (uint256) {
        _tokenIds++;
        return _tokenIds;
    }

    // 定义学习徽章的元数据结构
    // 包含课程详细信息
    struct BadgeMetadata {
        string courseName; // 课程名称
        uint256 completionDate; // 完成日期（时间戳）
        string instructor; // 授课讲师
        uint256 duration; // 课程学习时长（小时）
    }

    // 存储每个 Token ID 对应的元数据
    // 将 Token ID 映射到具体的徽章元数据
    mapping(uint256 => BadgeMetadata) private _badgeMetadata;

    // 追踪每个地址是否已获得徽章
    // 确保每个地址只能获得一个学习徽章
    mapping(address => bool) private _hasReceivedBadge;

    // 构造函数：初始化 NFT 合约
    // 设置 NFT 的名称和符号
    constructor() ERC721("LearningBadge", "LBADGE") Ownable(msg.sender) {}

    // 铸造徽章的函数
    // 只有合约拥有者可以调用
    function mintBadge(
        address student, // 学生地址
        string memory courseName, // 课程名称
        string memory instructor, // 授课讲师
        uint256 duration // 课程学习时长
    ) public onlyOwner {
        // 检查学生是否已经获得过徽章
        require(!_hasReceivedBadge[student], unicode"学生已经获得过徽章");

        // 自增 Token ID
        uint256 newTokenId = _incrementTokenIds();

        // 为学生铸造 NFT
        _safeMint(student, newTokenId);

        // 存储徽章元数据
        _badgeMetadata[newTokenId] = BadgeMetadata({
            courseName: courseName,
            completionDate: block.timestamp, // 使用当前区块时间戳
            instructor: instructor,
            duration: duration
        });

        // 标记该地址已获得徽章
        _hasReceivedBadge[student] = true;
    }

    // 获取特定 Token ID 的徽章元数据
    function getBadgeMetadata(
        uint256 tokenId
    ) public view returns (BadgeMetadata memory) {
        // 验证 Token 是否存在
        // require(_ownerOf(tokenId), unicode"徽章不存在");
        require(tokenId > 0 && tokenId <= _tokenIds, unicode"徽章不存在");
        return _badgeMetadata[tokenId];
    }

    // 重写 transferFrom 方法，使 NFT 不可转让
    // 任何尝试转让的操作都将被拒绝
    function transferFrom(address, address, uint256) public virtual override {
        revert(unicode"学习徽章不可转让");
    }

    // 重写 safeTransferFrom 方法，确保不可转让
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override {
        revert(unicode"学习徽章不可转让");
    }

    // 检查指定学生是否已获得徽章
    function hasStudentReceivedBadge(
        address student
    ) public view returns (bool) {
        return _hasReceivedBadge[student];
    }

    // 获取已铸造徽章的总数
    function totalBadgesMinted() public view returns (uint256) {
        return _tokenIds;
    }
}
