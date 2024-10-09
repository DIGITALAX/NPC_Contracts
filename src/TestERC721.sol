// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestERC721 is ERC721 {
    constructor() ERC721("Test Token", "TST") {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
