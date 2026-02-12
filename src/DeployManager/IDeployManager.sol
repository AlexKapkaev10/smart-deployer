// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/// @title IDeployManager
/// @author Aleksandr Kapkaev
/// @notice Interface for DeployManager contract, including custom errors, events, and external API
interface IDeployManager is IERC165 {
    // ----------------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------------

    /// @dev Reverts when deploy is called with a template that is not active
    error ContractNotActive();

    /// @dev Reverts when msg.value is less than the template's required deployment fee
    error NotEnoughFunds();

    /// @dev Reverts when the template address is not registered in the manager
    error ContractNotRegistered();

    /// @dev Reverts when the clone's initialize() call returns false or reverts
    error InitializationFailed();

    /// @dev Reverts when sending the deployment fee to the owner fails
    error TransferFailed();

    /// @dev Reverts when the address does not implement IUtilityContract (e.g. for addNewContract)
    error ContractIsNotUtilityContract();

    /// @dev Reverts when the contract is already registered
    error ContractAlreadyRegistered();

    // ----------------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------------

    /// @notice Emitted when a new utility contract template is registered
    /// @param _contractAddress Address of the utility contract template
    /// @param _fee Fee in wei required to deploy a clone of this template
    /// @param _isActive Whether the template is active and deployable
    /// @param _timestamp Block timestamp when the template was registered
    event NewContractAdded(address _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);

    /// @notice Emitted when deployment fee for a registered template is updated
    /// @param _contractAddress Address of the registered utility contract template
    /// @param _oldFee Previous fee in wei
    /// @param _newFee New fee in wei
    /// @param _timestamp Block timestamp when the fee was updated
    event ContractFeeUpdated(address _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);

    /// @notice Emitted when active status for a registered template is updated
    /// @param _contractAddress Address of the registered utility contract template
    /// @param _isActive True if the template can be deployed
    /// @param _timestamp Block timestamp when status was updated
    event ContractStatusUpdated(address _contractAddress, bool _isActive, uint256 _timestamp);

    /// @notice Emitted when a new clone is deployed from registered template
    /// @param _deployer Address that initiated deployment
    /// @param _contractAddress Address of the deployed clone
    /// @param _fee Amount in wei paid by deployer
    /// @param _timestamp Block timestamp when deployment was completed
    event NewDeployment(address _deployer, address _contractAddress, uint256 _fee, uint256 _timestamp);

    // ----------------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------------

    /// @notice Deploys a new clone of registered utility contract template
    /// @param _utilityContract Address of registered utility contract template
    /// @param _initData Initialization data passed to clone initialize
    /// @return Address of deployed clone
    /// @dev Emits NewDeployment event
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Registers utility contract template in DeployManager
    /// @param _contractAddress Address of utility contract template
    /// @param _fee Fee in wei required for deployment
    /// @param _isActive True if template can be deployed immediately
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updates deployment fee for registered utility contract template
    /// @param _contractAddress Address of registered utility contract template
    /// @param _newFee New fee in wei required for deployment
    function updateFee(address _contractAddress, uint256 _newFee) external;

    /// @notice Disables deployment for registered utility contract template
    /// @param _address Address of registered utility contract template
    /// @dev Sets _isActive to false
    function deactivateContract(address _address) external;

    /// @notice Enables deployment for registered utility contract template
    /// @param _address Address of registered utility contract template
    /// @dev Sets _isActive to true
    function activateContract(address _address) external;
}