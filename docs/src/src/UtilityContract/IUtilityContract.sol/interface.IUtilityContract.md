# IUtilityContract
**Inherits:**
IERC165

**Title:**
IUtilityContract

**Author:**
Aleksandr Kapkaev

Base interface for utility contracts deployed through DeployManager


## Functions
### initialize

Initializes the utility contract with the provided data

This function should be called by the DeployManager after deploying the contract


```solidity
function initialize(bytes memory _initData) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initData`|`bytes`|The initialization data for the utility contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the initialization was successful|


### getDeployManager

Shows DeployManager used for deployment of current contract


```solidity
function getDeployManager() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|DeployManager address|


## Errors
### DeployManagerCannotBeZero
Reverts when deploy manager address is zero


```solidity
error DeployManagerCannotBeZero();
```

### NotDeployManager
Reverts if caller is not DeployManager


```solidity
error NotDeployManager();
```

### FailedToDeployManager
Reverts if DeployManager validation failed throw validetDeployManager()


```solidity
error FailedToDeployManager();
```

### AlreadyInitialized
Reverts if the contract is already initialized


```solidity
error AlreadyInitialized();
```

