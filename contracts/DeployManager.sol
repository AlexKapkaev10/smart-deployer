// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IUtilityContract.sol";

contract DeployManager is Ownable {

    event NewContractAdded
    (
        address _contractAddress, 
        uint256 _fee, 
        bool _isActive, 
        uint256 _timeStamp
    );

    event ContarctFeeUpdated
    (
        address _contractAddress, 
        uint256 _oldFee, 
        uint256 _newFee, 
        uint256 _timestamp
    );

    event ContartStatusUpdated
    (
        address _contractAddress,
        bool _isActive,
        uint256 _timestamp
    );

    event NewDeployment
    (
        address _deployer,
        address _contractAddress,
        uint256 _fee,
        uint256 _timeStamp
    );

    constructor() Ownable(msg.sender) {

    }

    struct ContractInfo{
        uint256 fee;
        bool isActive;
        uint256 registredAt;
    }

    mapping (address => address[]) public deployedContracts;
    mapping (address => ContractInfo) public contractsData;

    error ContractNotActive();
    error NotEnoughtFunds();
    error ContractDoesNotRegistred();
    error InitializationFailed();
    error WithdrawFailed();

    function deploy
    (
        address _utilityContact, 
        bytes calldata _initData
    ) external payable returns (address) {
        ContractInfo memory info = contractsData[_utilityContact];
        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, NotEnoughtFunds());
        require(info.registredAt > 0, ContractDoesNotRegistred());

        address clone = Clones.clone(_utilityContact);

        require(IUtilityContract(clone).initialize(_initData), InitializationFailed());

        (bool success, ) = payable(owner()).call{value: msg.value}("");
        require(success, WithdrawFailed());

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(msg.sender, clone, msg.value, block.timestamp);

        return clone;
    }

    function addNewContract
    (
        address _contractAddress, 
        uint256 _fee, 
        bool _isActive
    ) external onlyOwner {
        contractsData[_contractAddress] = ContractInfo({
            fee: _fee, 
            isActive: _isActive,
            registredAt: block.timestamp
        });

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    function updateFee
    (
        address _contractAddress, 
        uint256 _newFee
    ) external onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractDoesNotRegistred());
        uint256 oldFee = contractsData[_contractAddress].fee;

        contractsData[_contractAddress].fee = _newFee;

        emit ContarctFeeUpdated(_contractAddress, oldFee, _newFee, block.timestamp);
    }

    function deactivateContract(address _contractAddress) external onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractDoesNotRegistred());
        contractsData[_contractAddress].isActive = false;

        emit ContartStatusUpdated(_contractAddress, false, block.timestamp);
    }

    function activateContract(address _contractAddress) external onlyOwner {
        require(contractsData[_contractAddress].registredAt > 0, ContractDoesNotRegistred());
        contractsData[_contractAddress].isActive = true;

        emit ContartStatusUpdated(_contractAddress, true, block.timestamp);
    }

}