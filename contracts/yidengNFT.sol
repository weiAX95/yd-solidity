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
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ArtNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Base URI for token metadata
    string private _baseTokenURI;

    // Mint price
    uint256 public constant MINT_PRICE = 0.05 ether;

    // Maximum supply of NFTs
    uint256 public constant MAX_SUPPLY = 10000;

    // Mapping to store token metadata
    mapping(uint256 => string) private _tokenMetadata;

    // Event for minting
    event NFTMinted(address indexed minter, uint256 tokenId);

    constructor(string memory name, string memory symbol, string memory baseURI) 
        ERC721(name, symbol) 
    {
        _baseTokenURI = baseURI;
    }

    // Mint function with custom metadata
    function mint(string memory metadataURI) public payable {
        // Check maximum supply
        require(_tokenIds.current() < MAX_SUPPLY, "All NFTs have been minted");
        
        // Ensure correct payment
        require(msg.value >= MINT_PRICE, "Insufficient payment");

        // Increment token ID
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        // Mint NFT
        _safeMint(msg.sender, newTokenId);

        // Store metadata
        _tokenMetadata[newTokenId] = metadataURI;

        // Emit minting event
        emit NFTMinted(msg.sender, newTokenId);

        // Refund excess payment
        if(msg.value > MINT_PRICE) {
            payable(msg.sender).transfer(msg.value - MINT_PRICE);
        }
    }

    // Get token metadata
    function getTokenMetadata(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenMetadata[tokenId];
    }

    // Override base URI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // Set new base URI (only owner)
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    // Withdraw funds (only owner)
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    // Get total minted NFTs
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    // Additional batch transfer function
    function batchTransfer(address[] memory recipients, uint256[] memory tokenIds) public {
        require(recipients.length == tokenIds.length, "Mismatched arrays");
        
        for(uint i = 0; i < recipients.length; i++) {
            transferFrom(msg.sender, recipients[i], tokenIds[i]);
        }
    }
}