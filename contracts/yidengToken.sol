// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YidengToken is ERC20, Ownable {
    // 事件定义
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    // 构造函数
    constructor(
        uint256 initialSupply
    ) ERC20("YidengToken", "YD") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // 铸币功能 - 只有管理员可调用
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // 销毁功能
    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    // 批量铸币功能
    function batchMint(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOwner {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        for (uint i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Cannot mint to zero address");
            require(amounts[i] > 0, "Amount must be greater than 0");
            _mint(recipients[i], amounts[i]);
            emit TokensMinted(recipients[i], amounts[i]);
        }
    }
}
