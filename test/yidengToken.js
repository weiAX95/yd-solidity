
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("yidengToken", function () {
    let yidengToken;
    let YidengToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        // 获取合约工厂
        YidengToken = await ethers.getContractFactory("YidengToken");
        // 获取测试账户
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        // 部署合约,初始供应量为1,000,000
        yidengToken = await YidengToken.deploy(1000000);
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await yidengToken.owner()).to.equal(owner.address);
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await yidengToken.balanceOf(owner.address);
            expect(await yidengToken.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            // 从owner转100个token到addr1
            await yidengToken.transfer(addr1.address, 100);
            const addr1Balance = await yidengToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(100);

            // 从addr1转50个token到addr2
            await yidengToken.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await yidengToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should fail if sender doesn't have enough tokens", async function () {
            const initialOwnerBalance = await yidengToken.balanceOf(owner.address);
            await expect(
                yidengToken.connect(addr1).transfer(owner.address, 1)
            ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
            expect(await yidengToken.balanceOf(owner.address)).to.equal(
                initialOwnerBalance
            );
        });
    });

    describe("Minting", function () {
        it("Should allow owner to mint tokens", async function () {
            await yidengToken.mint(addr1.address, 500);
            expect(await yidengToken.balanceOf(addr1.address)).to.equal(500);
        });

        it("Should fail if non-owner tries to mint tokens", async function () {
            await expect(
                yidengToken.connect(addr1).mint(addr2.address, 500)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });
    });

    describe("Burning", function () {
        it("Should allow users to burn their tokens", async function () {
            await yidengToken.transfer(addr1.address, 1000);
            await yidengToken.connect(addr1).burn(500);
            expect(await yidengToken.balanceOf(addr1.address)).to.equal(500);
        });
    });
});