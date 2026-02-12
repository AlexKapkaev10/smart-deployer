// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IUtilityContract
/// @author Aleksandr Kapkaev
/// @notice Base interface for utility contracts deployed through DeployManager
interface IUtilityContract is IERC165 {
    // ----------------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------------

    /// @dev Reverts when deploy manager address is zero
    error DeployManagerCannotBeZero();

    /// @dev Reverts if caller is not DeployManager
    error NotDeployManager();

    /// @dev Reverts if DeployManager validation failed throw validetDeployManager()
    error FailedToDeployManager();

    /// @dev Reverts if the contract is already initialized
    error AlreadyInitialized();

    // ----------------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------------

    /// @notice Initializes the utility contract with the provided data
    /// @param _initData The initialization data for the utility contract
    /// @return True if the initialization was successful
    /// @dev This function should be called by the DeployManager after deploying the contract
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Shows DeployManager used for deployment of current contract
    /// @return DeployManager address
    function getDeployManager() external view returns (address);
}