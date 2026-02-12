// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title ERC20Mock
/// @author Aleksandr Kapkaev
/// @notice Simple ERC20 token used for local testing and demos
contract ERC20Mock is ERC20 {
    /// @notice Mints initial supply to recipient on deployment
    /// @param recipient Address that receives initial token supply
    constructor(address recipient) payable ERC20("MyToken", "MTK") {
        _mint(recipient, 10000 * 10 ** decimals());
    }
}