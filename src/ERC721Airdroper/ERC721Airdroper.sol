// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC721Airdroper
/// @author Aleksandr Kapkaev
/// @notice Utility contract for batched ERC721 transfers from treasury to receivers
/// @dev Contract must be approved as operator for treasury NFTs before airdrop
contract ERC721Airdroper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    /// @notice Maximum receivers count in one airdrop call
    uint256 constant public MAX_AIRDROP_BATCH_SIZE = 300;

    /// @notice ERC721 token distributed by this contract
    IERC721 public token;

    /// @notice Source wallet from which NFTs are transferred
    address public treasury;

    /// @dev Reverts when batch size exceeds MAX_AIRDROP_BATCH_SIZE
    error BatchSizeExceeded();

    /// @dev Reverts when receivers and tokenIds arrays have different lengths
    error ArraysLengthMismatch();

    /// @dev Reverts when this contract is not approved as operator for treasury
    error NeedToApproveTokens();

    /// @notice Executes batch ERC721 transfers from treasury to receivers
    /// @param receivers Recipient addresses
    /// @param tokenIds Token IDs to transfer
    function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ArraysLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NeedToApproveTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < tokenIds.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IUtilityContract
    /// @dev Decodes (_deployManager, _token, _treasury, _owner)
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _token, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC721(_token);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @notice Builds initialize calldata for DeployManager clone deployment
    /// @param _deployManager DeployManager address
    /// @param _token ERC721 token address
    /// @param _treasury Source wallet for NFT transfers
    /// @param _owner Owner of deployed clone
    /// @return Encoded init data for initialize
    function getInitData(address _deployManager, address _token, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(_deployManager, _token, _treasury, _owner);
    }
}
