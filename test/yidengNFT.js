// 铸造徽章
function testMintBadge() public {
  address student = address(0x123);
  
  // 铸造区块链课程徽章
  vm.prank(owner);
  learningBadgeNFT.mintBadge(
      student, 
      "Blockchain Fundamentals", 
      "John Doe", 
      40
  );

  // 验证徽章已铸造
  assertEq(learningBadgeNFT.balanceOf(student), 1);
  
  // 获取并验证元数据
  LearningBadgeNFT.BadgeMetadata memory metadata = 
      learningBadgeNFT.getBadgeMetadata(1);
  
  assertEq(metadata.courseName, "Blockchain Fundamentals");
  assertEq(metadata.instructor, "John Doe");
}

// 测试不可转让
function testNonTransferable() public {
  address student = address(0x123);
  address recipient = address(0x456);
  
  vm.prank(owner);
  learningBadgeNFT.mintBadge(
      student, 
      "Solidity Programming", 
      "Jane Smith", 
      30
  );

  // 尝试转让应该失败
  vm.prank(student);
  vm.expectRevert("Learning badges are non-transferable");
  learningBadgeNFT.transferFrom(student, recipient, 1);
}