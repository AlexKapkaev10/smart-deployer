// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC1155Airdroper
/// @author Aleksandr Kapkaev
/// @notice Utility contract for batched ERC1155 transfers from treasury to receivers
/// @dev Contract must be approved as operator for treasury tokens before airdrop
contract ERC1155Airdroper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum receivers count in one airdrop call
    uint256 constant public MAX_AIRDROP_BATCH_SIZE = 10;

    /// @notice ERC1155 token distributed by this contract
    IERC1155 public token;

    /// @notice Source wallet from which tokens are transferred
    address public treasury;

    /// @dev Reverts when receivers and tokenIds arrays have different lengths
    error ReciversLengthMismatch();

    /// @dev Reverts when amounts and tokenIds arrays have different lengths
    error AmountsLengthMismatch();

    /// @dev Reverts when batch size exceeds MAX_AIRDROP_BATCH_SIZE
    error BatchSizeExceeded();

    /// @dev Reverts when this contract is not approved as operator for treasury
    error NeedToApproveTokens();

    /// @notice Executes batch ERC1155 transfers from treasury to receivers
    /// @param receivers Recipient addresses
    /// @param amounts Transfer amounts per recipient
    /// @param tokenIds Token IDs to transfer
    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ReciversLengthMismatch());
        require(amounts.length == tokenIds.length, AmountsLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < amounts.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i], amounts[i], "");
            unchecked { ++i; }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @dev Decodes (_deployManager, _token, _treasury, _owner)
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) = abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC1155(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Builds initialize calldata for DeployManager clone deployment
    /// @param _deployManager DeployManager address
    /// @param _token ERC1155 token address
    /// @param _treasury Source wallet for token transfers
    /// @param _owner Owner of deployed clone
    /// @return Encoded init data for initialize
    function getInitData(address _deployManager, address _token, address _treasury, address _owner) external pure returns (bytes memory) {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
