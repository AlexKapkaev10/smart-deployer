// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IUtilityContract.sol";

contract ERC721Airdroper is IUtilityContract {

    IERC721 public token;
    address public treasury;
    bool private initialized;

    error ReceiversAndTokenIdsMismatch();
    error AirdropContractNotApproved();
    error AlreadyInitialized();

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    function initialize(bytes memory _initData) external notInitialized returns (bool) {

        (address _tokenAddress, address _treasury) = abi.decode(_initData, (address, address));
        
        token = IERC721(_tokenAddress);
        treasury = _treasury;

        initialized = true;
        return true;
    }

    function airdrop(
        address[] calldata receivers,
        uint256[] calldata tokenIds
    ) external {
        require(
            receivers.length == tokenIds.length, 
            ReceiversAndTokenIdsMismatch()
        );

        require(
            token.isApprovedForAll(treasury, address(this)),
            AirdropContractNotApproved()
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            token.safeTransferFrom(
                treasury,
                receivers[i],
                tokenIds[i]
            );
        }
    }

    function getInitData
    (
        address _tokenAddress, 
        address _treasury
    ) external pure returns (bytes memory) {

        return abi.encode(_tokenAddress, _treasury);
    }
}
