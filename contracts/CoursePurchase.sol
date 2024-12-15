// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./yidengToken.sol";

contract CourseMarket is Ownable, ReentrancyGuard, Pausable {
    error CourseNotFound(string web2CourseId);
    error CourseAlreadyExists(string web2CourseId);
    error CourseNotActive(uint256 courseId);
    error AlreadyPurchased(uint256 courseId);
    error TransferFailed();
    // YiDeng代币合约实例
    YidengToken public yidengToken;

    // 课程结构体定义
    struct Course {
        string web2CourseId; // Web2平台的课程ID
        string name; // 课程名称
        uint256 price; // 课程价格(YD代币)
        bool isActive; // 课程是否可购买
        address creator; // 课程创建者地址
    }

    // 存储所有课程的映射：courseId => Course
    mapping(uint256 => Course) public courses;

    // web2CourseId到courseId的映射关系
    mapping(string => uint256) public web2ToCourseId;

    // 用户购买记录映射：用户地址 => courseId => 是否购买
    mapping(address => mapping(uint256 => bool)) public userCourses;

    // 课程总数计数器
    uint256 public courseCount;

    // 定义事件，记录课程购买
    event CoursePurchased(
        address indexed buyer,
        uint256 indexed courseId,
        string web2CourseId
    );
    // 记录课程添加
    event CourseAdded(string indexed web2CourseId, string name, uint256 price);
    event CourseUpdated(string indexed web2CourseId, string newName, uint256 newPrice);

    constructor(
        address payable _yiDengToken
    ) Ownable(msg.sender) ReentrancyGuard() Pausable() {
        require(_yiDengToken != address(0), "Invalid token address");
        yidengToken = YidengToken(_yiDengToken);
    }

    /**
     * @notice 使用web2CourseId购买课程
     * @param web2CourseId Web2平台的课程ID
     * @dev 用户通过Web2课程ID购买课程，自动查找对应的链上课程ID
     */
    function purchaseCourse(string memory web2CourseId) external {
        // 获取链上课程ID
        uint256 courseId = web2ToCourseId[web2CourseId];

        // 确保课程存在
        require(courseId > 0, "Course does not exist");

        // 获取课程信息
        Course memory course = courses[courseId];

        // 确保课程处于可购买状态
        require(course.isActive, "Course not active");

        // 确保用户未购买过该课程
        require(!userCourses[msg.sender][courseId], "Already purchased");

        // 确保web2CourseId匹配
        require(
            keccak256(abi.encodePacked(course.web2CourseId)) ==
                keccak256(abi.encodePacked(web2CourseId)),
            "Course ID mismatch"
        );

        // 调用YD代币合约的transferFrom函数，转移代币给课程创建者
        require(
            yidengToken.transferFrom(
                msg.sender, // 从购买者账户
                course.creator, // 转给课程创建者
                course.price // 转移课程价格对应的代币数量
            ),
            "Transfer failed"
        );

        // 记录购买状态
        userCourses[msg.sender][courseId] = true;

        // 触发购买事件
        emit CoursePurchased(msg.sender, courseId, web2CourseId);
    }

    /**
     * @notice 检查用户是否已购买课程
     * @param user 用户地址
     * @param web2CourseId Web2平台的课程ID
     * @return bool 是否已购买
     */
    function hasCourse(
        address user,
        string memory web2CourseId
    ) external view returns (bool) {
        uint256 courseId = web2ToCourseId[web2CourseId];
        require(courseId > 0, "Course does not exist");
        return userCourses[user][courseId];
    }

    /**
     * @notice 添加新课程
     * @param web2CourseId Web2平台的课程ID
     * @param name 课程名称
     * @param price 课程价格(YD代币)
     */
    function addCourse(
        string memory web2CourseId,
        string memory name,
        uint256 price
    ) external onlyOwner {
        // 确保web2CourseId不为空
        require(
            bytes(web2CourseId).length > 0,
            "Web2 course ID cannot be empty"
        );
        // 确保该web2CourseId尚未添加
        require(web2ToCourseId[web2CourseId] == 0, "Course already exists");

        // 递增课程计数器
        courseCount++;

        // 创建新课程
        courses[courseCount] = Course({
            web2CourseId: web2CourseId,
            name: name,
            price: price,
            isActive: true,
            creator: msg.sender
        });

        // 建立web2CourseId到courseId的映射关系
        web2ToCourseId[web2CourseId] = courseCount;
        emit CourseAdded(web2CourseId, name, price);
    }

    /**
     * @notice 更改课程信息
     * @param web2CourseId Web2平台的课程ID
     * @param name 课程名称
     * @param price 课程价格(YD代币)
     */
    function changeCourseInfo(
        string memory web2CourseId,
        string memory name,
        uint256 price
    ) external onlyOwner {
        require(
            bytes(web2CourseId).length > 0,
            "Web2 course ID cannot be empty"
        );
        require(web2ToCourseId[web2CourseId] == 1, "Course not exists");

        uint256 courseId = web2ToCourseId[web2CourseId];
        
        courses[courseId].name  = name;
        courses[courseId].price  = price;

        emit CourseUpdated(web2CourseId, name, price);
    }

    /**
     * @notice 更改课程状态
     * @param web2CourseId Web2平台的课程ID
     */
    function toggleCourse(string memory web2CourseId) public onlyOwner {
        uint256 courseId = web2ToCourseId[web2CourseId];
        require(courseId > 0 && courseId <= courseCount, "Invalid course ID");
        courses[courseId].isActive = !courses[courseId].isActive;
    }

    /**
     * @notice 批量查询功能
     * @param user 用户地址
     * @param web2CourseIds Web2平台的课程ID
     * @return results 返回每个课程的购买状态数组
     */
    function batchHasCourses(
        address user,
        string[] memory web2CourseIds
    ) external view returns (bool[] memory) {
        bool[] memory results = new bool[](web2CourseIds.length);
        for (uint i = 0; i < web2CourseIds.length; i++) {
            uint256 courseId = web2ToCourseId[web2CourseIds[i]];
            if (courseId > 0) {
                results[i] = userCourses[user][courseId];
            }
        }
        return results;
    }

    /**
     * @notice 获取用户所有已购课程
     * @param user 用户地址
     * @return userOwnedCourses 返回用户所有课程
     */
    function getUserCourses(address user) external view returns (Course[] memory) {
        uint256 purchasedCount = 0;
        for(uint256 i = 1; i <= courseCount; i++) {
            if(userCourses[user][i]) {
                purchasedCount++;
            }
        }
        
        Course[] memory userOwnedCourses = new Course[](purchasedCount);
        uint256 currentIndex = 0;
        
        for(uint256 i = 1; i <= courseCount; i++) {
            if(userCourses[user][i]) {
                userOwnedCourses[currentIndex] = courses[i];
                currentIndex++;
            }
        }
        
        return userOwnedCourses;
    }
}