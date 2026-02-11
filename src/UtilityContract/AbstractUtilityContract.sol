// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import {IUtilityContract} from "./IUtilityContract.sol";

/// @title AbstractUtilityContract
/// @author Aleksandr Kapkaev
/// @notice Base implementation for utility contracts initialized via DeployManager
/// @dev Validates deploy manager through ERC-165 interface detection
abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    /// @notice DeployManager address assigned during initialization
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes memory _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        setDeployManager(deployManager);
        return true;
    }

    /// @dev Sets and validates deploy manager address
    /// @param _deployManager Candidate deploy manager address
    function setDeployManager(address _deployManager) internal virtual {
        if (!validateDeployManager(_deployManager)) {
            revert FailedToDeployManager();
        }
        deployManager = _deployManager;
    }

    /// @dev Ensures deploy manager address is non-zero and supports IDeployManager interface
    /// @param _deployManager Candidate deploy manager address
    /// @return True when validation succeeds
    function validateDeployManager(address _deployManager) internal view returns (bool) {
        if (_deployManager == address(0)) {
            revert DeployManagerCannotBeZero();
        }

        bytes4 interfaceId = type(IDeployManager).interfaceId;

        if (!IDeployManager(_deployManager).supportsInterface(interfaceId)) {
            revert NotDeployManager();
        }

        return true;
    }

    /// @inheritdoc IUtilityContract
    function getDeployManager() external view virtual override returns (address) {
        return deployManager;
    }

    /// @dev ERC-165 support for IUtilityContract and inherited interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}