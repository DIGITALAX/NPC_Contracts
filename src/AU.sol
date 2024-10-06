// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AU is ERC20 {
    constructor() ERC20("Autonomy Units", "AU") {}
}
