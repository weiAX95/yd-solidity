// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 Chainlink 相关的库和接口
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VideoAuth is ChainlinkClient, Ownable {
    // 定义 Chainlink 相关的变量
    bytes32 private jobId;
    uint256 private fee;

    // 定义视频权限验证的结构体
    struct VideoPermission {
        uint256 videoId;
        address user;
        bool hasPermission;
    }

    // 存储视频权限验证的结果
    mapping(uint256 => VideoPermission) public videoPermissions;

    // 初始化 Chainlink 相关的变量
    constructor() {
        // TODO
        // 设置公共 Chainlink 代币地址
        _setChainlinkToken(0x0000000000000000000000000000000000000000);
        jobId = "YOUR_JOB_ID"; // 替换为实际的 Chainlink 作业 ID
        fee = 0.1 * 10 ** 18; // 替换为实际的 Chainlink 费用
    }

    // 验证用户是否有权限观看视频
    function verifyVideoPermission(
        uint256 _videoId,
        address _user
    ) public returns (bool) {
        // 检查视频是否存在
        require(
            videoPermissions[_videoId].videoId == _videoId,
            "Video does not exist"
        );

        // 检查用户是否已经验证过权限
        if (videoPermissions[_videoId].user == _user) {
            return videoPermissions[_videoId].hasPermission;
        }

        // 如果用户没有验证过权限，返回 false
        return false;
    }

    // 发起 Chainlink 请求，验证用户权限
    function requestVideoPermission(
        uint256 _videoId,
        address _user
    ) public onlyOwner {
        require(
            videoPermissions[_videoId].videoId == _videoId,
            "Video does not exist"
        );

        Chainlink.Request memory request = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );
        request.add("videoId", _videoId);
        request.add("user", _user);

        // 发送 Chainlink 请求
        _sendChainlinkRequest(request, fee);
    }

    // Chainlink 回调函数，处理权限验证结果
    function fulfill(
        bytes32 _requestId,
        bool _hasPermission
    ) public recordChainlinkFulfillment(_requestId) {
        // 获取视频 ID 和用户地址
        uint256 videoId = uint256(keccak256(abi.encodePacked(_requestId)));
        address user = Chainlink.Request(_requestId).get("user");

        // 存储权限验证结果
        videoPermissions[videoId] = VideoPermission(
            videoId,
            user,
            _hasPermission
        );
    }
}
