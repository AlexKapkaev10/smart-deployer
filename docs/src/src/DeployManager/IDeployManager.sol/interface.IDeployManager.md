# IDeployManager
**Inherits:**
IERC165

**Title:**
IDeployManager

**Author:**
Aleksandr Kapkaev

Interface for DeployManager contract, including custom errors, events, and external API


## Functions
### deploy

Deploys a new clone of registered utility contract template

Emits NewDeployment event


```solidity
function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_utilityContract`|`address`|Address of registered utility contract template|
|`_initData`|`bytes`|Initialization data passed to clone initialize|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Address of deployed clone|


### addNewContract

Registers utility contract template in DeployManager


```solidity
function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of utility contract template|
|`_fee`|`uint256`|Fee in wei required for deployment|
|`_isActive`|`bool`|True if template can be deployed immediately|


### updateFee

Updates deployment fee for registered utility contract template


```solidity
function updateFee(address _contractAddress, uint256 _newFee) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of registered utility contract template|
|`_newFee`|`uint256`|New fee in wei required for deployment|


### deactivateContract

Disables deployment for registered utility contract template

Sets _isActive to false


```solidity
function deactivateContract(address _address) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address of registered utility contract template|


### activateContract

Enables deployment for registered utility contract template

Sets _isActive to true


```solidity
function activateContract(address _address) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address of registered utility contract template|


## Events
### NewContractAdded
Emitted when a new utility contract template is registered


```solidity
event NewContractAdded(address _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the utility contract template|
|`_fee`|`uint256`|Fee in wei required to deploy a clone of this template|
|`_isActive`|`bool`|Whether the template is active and deployable|
|`_timestamp`|`uint256`|Block timestamp when the template was registered|

### ContractFeeUpdated
Emitted when deployment fee for a registered template is updated


```solidity
event ContractFeeUpdated(address _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered utility contract template|
|`_oldFee`|`uint256`|Previous fee in wei|
|`_newFee`|`uint256`|New fee in wei|
|`_timestamp`|`uint256`|Block timestamp when the fee was updated|

### ContractStatusUpdated
Emitted when active status for a registered template is updated


```solidity
event ContractStatusUpdated(address _contractAddress, bool _isActive, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddress`|`address`|Address of the registered utility contract template|
|`_isActive`|`bool`|True if the template can be deployed|
|`_timestamp`|`uint256`|Block timestamp when status was updated|

### NewDeployment
Emitted when a new clone is deployed from registered template


```solidity
event NewDeployment(address _deployer, address _contractAddress, uint256 _fee, uint256 _timestamp);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployer`|`address`|Address that initiated deployment|
|`_contractAddress`|`address`|Address of the deployed clone|
|`_fee`|`uint256`|Amount in wei paid by deployer|
|`_timestamp`|`uint256`|Block timestamp when deployment was completed|

## Errors
### ContractNotActive
Reverts when deploy is called with a template that is not active


```solidity
error ContractNotActive();
```

### NotEnoughFunds
Reverts when msg.value is less than the template's required deployment fee


```solidity
error NotEnoughFunds();
```

### ContractNotRegistered
Reverts when the template address is not registered in the manager


```solidity
error ContractNotRegistered();
```

### InitializationFailed
Reverts when the clone's initialize() call returns false or reverts


```solidity
error InitializationFailed();
```

### TransferFailed
Reverts when sending the deployment fee to the owner fails


```solidity
error TransferFailed();
```

### ContractIsNotUtilityContract
Reverts when the address does not implement IUtilityContract (e.g. for addNewContract)


```solidity
error ContractIsNotUtilityContract();
```

### ContractAlreadyRegistered
Reverts when the contract is already registered


```solidity
error ContractAlreadyRegistered();
```

## Structs
### ContractInfo
Stores registered contract information


```solidity
struct ContractInfo {
    uint256 fee;
    bool isDeployable;
    uint256 registeredAt;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`fee`|`uint256`|Deployment fee in wei|
|`isDeployable`|`bool`|Show deployable status|
|`registeredAt`|`uint256`|Timestamp when the contract was registered|

