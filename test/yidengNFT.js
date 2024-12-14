const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("yidengNFT", function () {
  let yidengNFT;
  let yidengNFT;
  let owner;
  let student;

  beforeEach(async function () {
    // 获取签名者
    [owner, student] = await ethers.getSigners();

    // 部署合约
    const yidengNFTFactory = await ethers.getContractFactory("YidengNFT");
    yidengNFT = await yidengNFTFactory.deploy();
  });

  it("应该成功铸造徽章", async function () {
    // 由所有者为学生铸造徽章
    await yidengNFT.mintBadge(
      student.address, 
      "区块链进阶", 
      "李四", 
      60
    );

    // 检查学生的徽章余额
    const balance = await yidengNFT.balanceOf(student.address);
    expect(balance).to.equal(1);

    // 检查徽章元数据
    const metadata = await yidengNFT.getBadgeMetadata(1);
    expect(metadata.courseName).to.equal("区块链进阶");
  });

  it("不应允许重复铸造", async function () {
    // 第一次铸造
    await yidengNFT.mintBadge(
      student.address, 
      "区块链基础", 
      "王五", 
      40
    );

    // 尝试第二次铸造，应该失败
    await expect(
      yidengNFT.mintBadge(
        student.address, 
        "另一个课程", 
        "赵六", 
        30
      )
    ).to.be.revertedWith("学生已经获得过徽章");
  });

  it("不应允许转让徽章", async function () {
    // 铸造徽章
    await yidengNFT.mintBadge(
      student.address, 
      "Web3安全", 
      "小李", 
      50
    );

    // 尝试转让，应该失败
    await expect(
      yidengNFT.connect(student).transferFrom(
        student.address, 
        owner.address, 
        1
      )
    ).to.be.revertedWith("学习徽章不可转让");
  });
});