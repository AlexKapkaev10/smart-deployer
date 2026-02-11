// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/IUtilityContract.sol";
import "./IDeployManager.sol";

/// @title DeployManager
/// @author Aleksandr Kapkaev
/// @notice Registry and clone factory for utility contracts; owner registers templates (fee + active flag);
///         anyone can deploy an EIP-1167 clone of an active template by paying at least the fee; fee is sent to owner
/// @dev Uses OpenZeppelin Clones (minimal proxy), Ownable; templates must implement IUtilityContract
contract DeployManager is IDeployManager, Ownable, ERC165 {
    constructor() Ownable(msg.sender) payable {}

    /// @dev Per-template data: deployment fee, whether deploy is allowed, and registration time (0 = not registered)
    struct ContractInfo {
        uint256 fee;
        bool isActive;
        uint256 registredAt;
    }

    /// @dev Deployer address => list of clone addresses they deployed (append-only)
    mapping(address => address[]) public deployedContracts;

    /// @dev Template address => registration data; registredAt > 0 means the template is registered
    mapping(address => ContractInfo) public contractsData;

    /// @inheritdoc IDeployManager
    /// @dev Clones via Clones.clone, initializes with _initData, forwards full msg.value to owner (no refund for excess)
    function deploy(address _utilityContract, bytes calldata _initData) external override payable returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, NotEnoughFunds());
        require(info.registredAt > 0, ContractNotRegistered());

        address clone = Clones.clone(_utilityContract);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        (bool success, ) = payable(owner()).call{value: msg.value}("");
        require(success, TransferFailed());

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    /// @inheritdoc IDeployManager
    /// @dev Overwrites existing registration if _contractAddress was already registered
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        require(IUtilityContract(_contractAddress).supportsInterface(type(IUtilityContract).interfaceId), ContractIsNotUtilityContract());
        contractsData[_contractAddress] = ContractInfo({fee: _fee, isActive: _isActive, registredAt: block.timestamp});
        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractNotRegistered());

        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function deactivateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractNotRegistered());

        contractsData[_address].isActive = false;

        emit ContractStatusUpdated(_address, false, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function activateContract(address _address) external override onlyOwner {
        require(contractsData[_address].registredAt > 0, ContractNotRegistered());

        contractsData[_address].isActive = true;

        emit ContractStatusUpdated(_address, true, block.timestamp);
    }

    /// @dev ERC-165: supports IDeployManager and inherited interfaces
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return 
        interfaceId == type(IDeployManager).interfaceId || 
        super.supportsInterface(interfaceId);
    }
}