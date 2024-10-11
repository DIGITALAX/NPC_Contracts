// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("Test Token", "TST") {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount * 1000000000000000000);
    }
}
