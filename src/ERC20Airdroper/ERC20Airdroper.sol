// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20Airdroper
/// @author Aleksandr Kapkaev
/// @notice Utility contract for batched ERC20 transfers from treasury to receivers
/// @dev Contract must be approved to spend treasury tokens before airdrop
contract ERC20Airdroper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum receivers count in one airdrop call
    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC20 token distributed by this contract
    IERC20 public token;

    /// @notice Fixed token amount used as approval floor check in airdrop
    uint256 public amount;

    /// @notice Source wallet from which tokens are transferred
    address public treasury;

    /// @dev Reverts when receivers and amounts arrays have different lengths
    error ArraysLengthMismatch();

    /// @dev Reverts when allowance from treasury to this contract is lower than configured amount
    error NotEnoughApprovedTokens();

    /// @dev Reverts when ERC20 transferFrom returns false
    error TransferFailed();

    /// @dev Reverts when batch size exceeds MAX_AIRDROP_BATCH_SIZE
    error BatchSizeExceeded();

    /// @notice Executes batch ERC20 transfers from treasury to receivers
    /// @param receivers Recipient addresses
    /// @param amounts Transfer amounts per recipient
    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == amounts.length, ArraysLengthMismatch());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            require(token.transferFrom(treasuryAddress, receivers[i], amounts[i]), TransferFailed());
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @dev Decodes (_deployManager, _token, _amount, _treasury, _owner)
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, uint256 _amount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        setDeployManager(_deployManager);

        token = IERC20(_token);
        amount = _amount;
        treasury = _treasury;

        _transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Builds initialize calldata for DeployManager clone deployment
    /// @param _deployManager DeployManager address
    /// @param _token ERC20 token address
    /// @param _amount Minimum approved amount required in allowance check
    /// @param _treasury Source wallet for token transfers
    /// @param _owner Owner of deployed clone
    /// @return Encoded init data for initialize
    function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _amount, _treasury, _owner);
    }
}
