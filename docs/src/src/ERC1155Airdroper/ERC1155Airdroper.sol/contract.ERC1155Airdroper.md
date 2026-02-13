# ERC1155Airdroper
**Inherits:**
[AbstractUtilityContract](/src/UtilityContract/AbstractUtilityContract.sol/abstract.AbstractUtilityContract.md), Ownable

**Title:**
ERC1155Airdroper

**Author:**
Aleksandr Kapkaev

Utility contract for batched ERC1155 transfers from treasury to receivers

Contract must be approved as operator for treasury tokens before airdrop


## State Variables
### MAX_AIRDROP_BATCH_SIZE
Maximum receivers count in one airdrop call


```solidity
uint256 public constant MAX_AIRDROP_BATCH_SIZE = 10
```


### token
ERC1155 token distributed by this contract


```solidity
IERC1155 public token
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

Executes batch ERC1155 transfers from treasury to receivers


```solidity
function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Recipient addresses|
|`amounts`|`uint256[]`|Transfer amounts per recipient|
|`tokenIds`|`uint256[]`|Token IDs to transfer|


### initialize

Initializes the utility contract with the provided data

Decodes (_deployManager, _token, _treasury, _owner)


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
function getInitData(address _deployManager, address _token, address _treasury, address _owner)
    external
    pure
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployManager`|`address`|DeployManager address|
|`_token`|`address`|ERC1155 token address|
|`_treasury`|`address`|Source wallet for token transfers|
|`_owner`|`address`|Owner of deployed clone|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes`|Encoded init data for initialize|


## Errors
### ReciversLengthMismatch
Reverts when receivers and tokenIds arrays have different lengths


```solidity
error ReciversLengthMismatch();
```

### AmountsLengthMismatch
Reverts when amounts and tokenIds arrays have different lengths


```solidity
error AmountsLengthMismatch();
```

### BatchSizeExceeded
Reverts when batch size exceeds MAX_AIRDROP_BATCH_SIZE


```solidity
error BatchSizeExceeded();
```

### NeedToApproveTokens
Reverts when this contract is not approved as operator for treasury


```solidity
error NeedToApproveTokens();
```

