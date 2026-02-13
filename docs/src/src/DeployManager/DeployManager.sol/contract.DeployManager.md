# DeployManager
**Inherits:**
[IDeployManager](/src/DeployManager/IDeployManager.sol/interface.IDeployManager.md), Ownable, ERC165

**Title:**
DeployManager - Factory for utility contracts

**Author:**
Aleksandr Kapkaev

Allows users to deploy utility contracts by cloning registered templates.

Uses OpenZeppelin's Clones and Ownable; assumes templates implement IUtilityContract.


## State Variables
### deployedContracts
Maps deployer address => an array of addresses of deployed contracts addresses


```solidity
mapping(address => address[]) public deployedContracts
```


### contractsData
Maps registered contract address => registration data


```solidity
mapping(address => IDeployManager.ContractInfo) public contractsData
```


## Functions
### constructor


```solidity
constructor() payable Ownable(msg.sender);
```

### deploy

Deploys a new clone of registered utility contract template

Emits NewDeployment event


```solidity
function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address);
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
function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner;
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
function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner;
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
function deactivateContract(address _address) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address of registered utility contract template|


### activateContract

Enables deployment for registered utility contract template

Sets _isActive to true


```solidity
function activateContract(address _address) external override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address of registered utility contract template|


### supportsInterface

See {IERC165-supportsInterface}.


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool);
```

