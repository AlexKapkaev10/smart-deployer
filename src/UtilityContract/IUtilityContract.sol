// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IUtilityContract
/// @author Aleksandr Kapkaev
/// @notice Base interface for utility contracts deployed through DeployManager
interface IUtilityContract is IERC165 {
    /// @dev Reverts when deploy manager address is zero
    error DeployManagerCannotBeZero();

    /// @dev Reverts when provided address does not support IDeployManager
    error NotDeployManager();

    /// @dev Reverts when setting deploy manager fails validation
    error FailedToDeployManager();

    /// @notice Initializes clone instance with encoded params
    /// @param _initData Encoded initialization data
    /// @return True when initialization succeeds
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Returns DeployManager address associated with this utility contract
    /// @return DeployManager address
    function getDeployManager() external view returns (address);
}