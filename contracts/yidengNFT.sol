// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ArtNFT is ERC721, Ownable {
  // 替换 Counters
  uint256 private _nextTokenId;

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

  constructor(
    string memory name,
    string memory symbol,
    string memory baseURI
  ) ERC721(name, symbol) Ownable(msg.sender) {
    _baseTokenURI = baseURI;
  }

  // Mint function with custom metadata
  function mint(string memory metadataURI) public payable {
    // Check maximum supply
    require(_nextTokenId < MAX_SUPPLY, 'All NFTs have been minted');

    // Ensure correct payment
    require(msg.value >= MINT_PRICE, 'Insufficient payment');

    // Increment token ID
    uint256 tokenId = _nextTokenId++;

    // Mint NFT
    _safeMint(msg.sender, tokenId);

    // Store metadata
    _tokenMetadata[tokenId] = metadataURI;

    // Emit minting event
    emit NFTMinted(msg.sender, tokenId);

    // Refund excess payment
    if (msg.value > MINT_PRICE) {
      payable(msg.sender).transfer(msg.value - MINT_PRICE);
    }
  }

  // Get token metadata
  function getTokenMetadata(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), 'Token does not exist');
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
    return _nextTokenId;
  }

  // Additional batch transfer function
  function batchTransfer(address[] memory recipients, uint256[] memory tokenIds) public {
    require(recipients.length == tokenIds.length, 'Mismatched arrays');

    for (uint i = 0; i < recipients.length; i++) {
      transferFrom(msg.sender, recipients[i], tokenIds[i]);
    }
  }

  // 添加 _exists 函数
  function _exists(uint256 tokenId) internal view returns (bool) {
    return tokenId < _nextTokenId;
  }
}
