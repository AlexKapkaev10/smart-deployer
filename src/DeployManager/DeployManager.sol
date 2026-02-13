// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/IUtilityContract.sol";
import "./IDeployManager.sol";

/// @title DeployManager - Factory for utility contracts
/// @author Aleksandr Kapkaev
/// @notice Allows users to deploy utility contracts by cloning registered templates.
/// @dev Uses OpenZeppelin's Clones and Ownable; assumes templates implement IUtilityContract.
contract DeployManager is IDeployManager, Ownable, ERC165 {
    constructor() payable Ownable(msg.sender) {}

    /// @dev Maps deployer address => an array of addresses of deployed contracts addresses
    mapping(address => address[]) public deployedContracts;

    /// @dev Maps registered contract address => registration data
    mapping(address => IDeployManager.ContractInfo) public contractsData;

    /// @inheritdoc IDeployManager
    function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isDeployable, ContractNotActive());
        require(msg.value >= info.fee, NotEnoughFunds());
        require(info.registeredAt > 0, ContractNotRegistered());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        (bool success,) = payable(owner()).call{value: msg.value}("");
        require(success, TransferFailed());

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    /// @inheritdoc IDeployManager
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        require(
            IUtilityContract(_contractAddress).supportsInterface(type(IUtilityContract).interfaceId),
            ContractIsNotUtilityContract()
        );

        require(contractsData[_contractAddress].registeredAt == 0, ContractAlreadyRegistered());

        contractsData[_contractAddress] =
            ContractInfo({fee: _fee, isDeployable: _isActive, registeredAt: block.timestamp});
        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractNotRegistered());

        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function deactivateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registeredAt > 0, ContractNotRegistered());

        contractsData[_address].isDeployable = false;

        emit ContractStatusUpdated(_address, false, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function activateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registeredAt > 0, ContractNotRegistered());

        contractsData[_address].isDeployable = true;

        emit ContractStatusUpdated(_address, true, block.timestamp);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IDeployManager).interfaceId || super.supportsInterface(interfaceId);
    }
}
