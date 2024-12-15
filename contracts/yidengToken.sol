// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract YidengToken is ERC20, Ownable {
  // 常量定义
  uint256 public constant EXCHANGE_RATE = 1000; // 1 ETH = 1000 YD
  uint256 public constant ETH_PRICE = 4000; // ETH价格 $4000
  uint256 public constant COMPANY_VALUATION = 3000000; // 公司估值 300万美元

  // 代币分配比例
  uint256 public constant TEAM_SHARE = 20; // 20%
  uint256 public constant MARKETING_SHARE = 10; // 10%
  uint256 public constant COMMUNITY_SHARE = 10; // 10%
  uint256 public constant PUBLIC_SALE_SHARE = 60; // 60%

  // 地址
  address public teamWallet;
  address public marketingWallet;
  address public communityWallet;

  // 状态变量
  bool public initialized = false;

  // 事件定义
  // 代币铸造
  event TokensMinted(address indexed to, uint256 amount);
  // 代币销毁
  event TokensBurned(address indexed from, uint256 amount);
  // 代币分配
  event TokensDistributed(
    uint256 teamAmount,
    uint256 marketingAmount,
    uint256 communityAmount,
    uint256 publicAmount
  );
  // 代币购买
  event TokensPurchased(address indexed buyer, uint256 amount, uint256 ethAmount);
  // 代币售出
  event TokensSold(address indexed seller, uint256 amount, uint256 ethAmount);
  // 代币转账
  constructor() ERC20('YidengToken', 'YD') Ownable(msg.sender) {}

  // 初始化代币分配
  function initialize(
    address _teamWallet, // 团队地址
    address _marketingWallet, // 市场地址
    address _communityWallet // 社区地址
  ) external onlyOwner {
    require(!initialized, 'Already initialized');
    require(
      _teamWallet != address(0) && _marketingWallet != address(0) && _communityWallet != address(0),
      'Invalid addresses'
    );

    // 计算总代币供应量
    // 公司估值 / ETH价格 = 需要的ETH数量
    uint256 requiredEth = (COMPANY_VALUATION * 1e18) / ETH_PRICE; // 750 ETH
    // ETH数量 * 兑换比例 = 代币数量
    uint256 baseSupply = requiredEth * EXCHANGE_RATE; // 750,000 YD
    // 基础供应量 / 公售比例 = 总供应量
    uint256 totalSupply = (baseSupply * 100) / PUBLIC_SALE_SHARE; // 1,250,000 YD

    // 计算各部分分配数量
    uint256 teamAmount = (totalSupply * TEAM_SHARE) / 100;
    uint256 marketingAmount = (totalSupply * MARKETING_SHARE) / 100;
    uint256 communityAmount = (totalSupply * COMMUNITY_SHARE) / 100;
    uint256 publicAmount = (totalSupply * PUBLIC_SALE_SHARE) / 100;

    // 分配代币
    _mint(_teamWallet, teamAmount);
    _mint(_marketingWallet, marketingAmount);
    _mint(_communityWallet, communityAmount);
    _mint(address(this), publicAmount); // 公售部分保留在合约中

    teamWallet = _teamWallet;
    marketingWallet = _marketingWallet;
    communityWallet = _communityWallet;

    initialized = true;

    emit TokensDistributed(teamAmount, marketingAmount, communityAmount, publicAmount);
  }

  // 购买代币
  function buyTokens() public payable {
    require(initialized, 'Not initialized');
    require(msg.value > 0, 'Send ETH to buy tokens');

    uint256 tokenAmount = msg.value * EXCHANGE_RATE;
    require(balanceOf(address(this)) >= tokenAmount, 'Insufficient tokens for sale');

    _transfer(address(this), msg.sender, tokenAmount);
    emit TokensPurchased(msg.sender, tokenAmount, msg.value);
  }

  // 售出代币
  function sellTokens(uint256 tokenAmount) public {
    require(initialized, 'Not initialized');
    require(tokenAmount > 0, 'Specify an amount of tokens');
    require(balanceOf(msg.sender) >= tokenAmount, 'Insufficient tokens');

    uint256 ethAmount = tokenAmount / EXCHANGE_RATE;
    require(address(this).balance >= ethAmount, 'Insufficient ETH in contract');

    _transfer(msg.sender, address(this), tokenAmount);
    payable(msg.sender).transfer(ethAmount);

    emit TokensSold(msg.sender, tokenAmount, ethAmount);
  }

  // 获取代币价格（以 ETH 计）
  function getTokenPrice() public pure returns (uint256) {
    return 1 ether / EXCHANGE_RATE;
  }

  // 查看合约ETH余额
  function getContractBalance() public view returns (uint256) {
    return address(this).balance;
  }

  // 允许合约接收 ETH
  receive() external payable {}
  fallback() external payable {}
}
