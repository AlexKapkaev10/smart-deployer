# ERC20Airdroper
**Inherits:**
[AbstractUtilityContract](/src/UtilityContract/AbstractUtilityContract.sol/abstract.AbstractUtilityContract.md), Ownable

**Title:**
ERC20Airdroper

**Author:**
Aleksandr Kapkaev

Utility contract for batched ERC20 transfers from treasury to receivers

Contract must be approved to spend treasury tokens before airdrop


## State Variables
### MAX_AIRDROP_BATCH_SIZE
Maximum receivers count in one airdrop call


```solidity
uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300
```


### token
ERC20 token distributed by this contract


```solidity
IERC20 public token
```


### amount
Fixed token amount used as approval floor check in airdrop


```solidity
uint256 public amount
```


### treasury
Source wallet from which tokens are transferred


```solidity
address public treasury
```


## Functions
### constructor


```solidity
constructor() payable Ownable(msg.sender);
```

### airdrop

Executes batch ERC20 transfers from treasury to receivers


```solidity
function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Recipient addresses|
|`amounts`|`uint256[]`|Transfer amounts per recipient|


### initialize

Initializes the utility contract with the provided data

Decodes (_deployManager, _token, _amount, _treasury, _owner)


```solidity
function initialize(bytes memory _initData) external override notInitialized returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initData`|`bytes`|The initialization data for the utility contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the initialization was successful|


### getInitData

Builds initialize calldata for DeployManager clone deployment


```solidity
function getInitData(address _deployManager, address _token, uint256 _amount, address _treasury, address _owner)
    external
    pure
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|DeployManager address|
|`_token`|`address`|ERC20 token address|
|`_amount`|`uint256`|Minimum approved amount required in allowance check|
|`_treasury`|`address`|Source wallet for token transfers|
|`_owner`|`address`|Owner of deployed clone|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Encoded init data for initialize|


## Errors
### ArraysLengthMismatch
Reverts when receivers and amounts arrays have different lengths


```solidity
error ArraysLengthMismatch();
```

### NotEnoughApprovedTokens
Reverts when allowance from treasury to this contract is lower than configured amount


```solidity
error NotEnoughApprovedTokens();
```

### TransferFailed
Reverts when ERC20 transferFrom returns false


```solidity
error TransferFailed();
```

### BatchSizeExceeded
Reverts when batch size exceeds MAX_AIRDROP_BATCH_SIZE


```solidity
error BatchSizeExceeded();
```

