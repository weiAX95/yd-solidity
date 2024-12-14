// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YidengToken is ERC20, Ownable {
    // 铸币事件
    event TokensMinted(address indexed to, uint256 amount);
    // 销毁事件
    event TokensBurned(address indexed from, uint256 amount);

    constructor(
        uint256 initialSupply
    ) ERC20("Yideng Token", "YDG") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // 铸造新代币，只有合约拥有者可以调用
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // 销毁代币
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}
