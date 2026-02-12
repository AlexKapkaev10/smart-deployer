// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "./IVesting.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Vesting
/// @author Aleksandr Kapkaev
/// @notice Linear vesting utility contract initialized by DeployManager clone flow
/// @dev Supports per-beneficiary schedules with cliff, linear unlock, cooldown, and minimal claim amount
contract Vesting is IVesting, AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    /// @notice ERC20 token distributed by vesting schedules
    IERC20 public token;

    /// @dev Initialization guard for clone pattern
    bool private initialized;

    /// @notice Sum of all tokens currently reserved by active vesting schedules
    uint256 public allocatedTokens;

    /// @notice Beneficiary address => vesting schedule
    mapping(address => IVesting.VestingInfo) public vestings;

    /// @dev Reverts when initialize was already called
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    /// @inheritdoc IVesting
    function claim() public override {
        VestingInfo storage vesting = vestings[msg.sender];

        require(vesting.totalAmount > 0, VestingNotFound());
        require(block.timestamp > vesting.startTime + vesting.cliff, CliffNotReached());
        require(block.timestamp >= vesting.lastClaimTime + vesting.claimCooldown, CooldownNotPassed());

        uint256 claimable = claimableAmount(msg.sender);
        require(claimable > 0, NothingToClaim());
        require(claimable >= vesting.minClaimAmount, BelowMinimalClaimAmount());
        require(claimable + vesting.claimed <= vesting.totalAmount, CantClaimMoreThanTotalAmount());

        vesting.claimed += claimable;
        vesting.lastClaimTime = block.timestamp;
        allocatedTokens -= claimable;

        require(token.transfer(msg.sender, claimable), TransferFailed());

        emit Claim(msg.sender, claimable, block.timestamp);
    }

    /// @notice Returns total vested amount (including already claimed part)
    /// @param _claimer Beneficiary address
    /// @return Amount that should be vested at current timestamp
    function vestedAmount(address _claimer) internal view returns (uint256) {
        VestingInfo storage vesting = vestings[_claimer];
        if (block.timestamp < vesting.startTime + vesting.cliff) return 0;

        uint256 passedTime = block.timestamp - (vesting.startTime + vesting.cliff);
        if (passedTime > vesting.duration) {
            passedTime = vesting.duration;
        }
        return (vesting.totalAmount * passedTime) / vesting.duration;
    }

    /// @inheritdoc IVesting
    function claimableAmount(address _claimer) public view override returns (uint256) {
        VestingInfo storage vesting = vestings[_claimer];
        if (block.timestamp < vesting.startTime + vesting.cliff) return 0;

        return vestedAmount(_claimer) - vesting.claimed;
    }

    /// @inheritdoc IVesting
    function startVesting(IVesting.VestingParams calldata params) external override onlyOwner {
        if (params.beneficiary == address(0)) revert InvalidBeneficiary();
        if (params.duration == 0) revert DurationCantBeZero();
        if (params.totalAmount == 0) revert AmountCantBeZero();

        uint256 blockTimestamp = block.timestamp;
        
        if (params.startTime < blockTimestamp) revert StartTimeShouldBeFuture(params.startTime, blockTimestamp);
        if (params.claimCooldown > params.duration) revert CooldownCantBeLongerThanDuration();
        
        uint256 availableBalance = token.balanceOf(address(this)) - allocatedTokens;
        
        if (availableBalance < params.totalAmount) revert InfsufficientBalance(availableBalance, params.totalAmount);

        VestingInfo storage vesting = vestings[params.beneficiary];

        if (vesting.isCreated && vesting.totalAmount != vesting.claimed){
            revert VestingAlreadyExist();
        }

        vesting.totalAmount = params.totalAmount;
        vesting.startTime = params.startTime;
        vesting.cliff = params.cliff;
        vesting.duration = params.duration;
        vesting.claimed = 0;
        vesting.lastClaimTime = 0;
        vesting.claimCooldown = params.claimCooldown;
        vesting.minClaimAmount = params.minClaimAmount;
        vesting.isCreated = true;

        unchecked {
            allocatedTokens = allocatedTokens + params.totalAmount;
        }

        emit VestingCreated(params.beneficiary, params.totalAmount, blockTimestamp);
    }

    /// @inheritdoc IVesting
    function withdrawUnallocated(address _to) external override onlyOwner {
        uint256 available = token.balanceOf(address(this)) - allocatedTokens;
        require(available > 0, NothingToWithdraw());

        require(token.transfer(_to, available), WithdrawTransferFailed());

        emit TokensWithdrawn(_to, available);
    }

    /// @inheritdoc IUtilityContract
    /// @dev Decodes (_deployManager, _token, _owner) and configures contract once
    function initialize(bytes memory _initData) external override(AbstractUtilityContract, IUtilityContract) notInitialized returns (bool) {
        ( address _deployManager, address _token, address _owner) = abi.decode(_initData, (address, address, address));

        setDeployManager(_deployManager);
        token = IERC20(_token);
        Ownable.transferOwnership(_owner);

        initialized = true;
        return true;
    }

    /// @inheritdoc IVesting
    function getInitData(address _deployManager, address _token, address _owner) external pure override returns (bytes memory) {
        return abi.encode(_deployManager, _token, _owner);
    }
}
