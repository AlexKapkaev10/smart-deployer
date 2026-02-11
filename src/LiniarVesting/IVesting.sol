// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/IUtilityContract.sol";

/// @title IVesting
/// @author Aleksandr Kapkaev
/// @notice Interface for linear vesting utility contracts managed by DeployManager
interface IVesting is IUtilityContract {
    // ----------------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------------

    /// @dev Reverts when initialize is called more than once
    error AlreadyInitialized();

    /// @dev Reverts when a vesting schedule does not exist for the caller
    error VestingNotFound();

    /// @dev Reverts when claim is attempted before the cliff period ends
    error CliffNotReached();

    /// @dev Reverts when ERC20 transfer during claim fails
    error TransferFailed();

    /// @dev Reverts when there are no claimable tokens
    error NothingToClaim();

    /// @dev Reverts when contract balance minus allocated tokens is lower than requested amount
    error InfsufficientBalance();

    /// @dev Reverts when beneficiary already has an active vesting schedule
    error VestingAlreadyExist();

    /// @dev Reverts when provided token amount is zero
    error AmountCantBeZero();

    /// @dev Reverts when start timestamp is not in the future
    error StartTimeShouldBeFuture();

    /// @dev Reverts when vesting duration is zero
    error DurationCantBeZero();

    /// @dev Reverts when cliff is greater than or equal to duration
    error CliffCantBeLongerThanDuration();

    /// @dev Reverts when claim cooldown is greater than or equal to duration
    error CooldownCantBeLongerThanDuration();

    /// @dev Reverts when beneficiary address is zero
    error InvalidBeneficiary();

    /// @dev Reverts when current claimable amount is below minClaimAmount
    error BelowMinimalClaimAmount();

    /// @dev Reverts when claim is attempted before cooldown ends
    error CooldownNotPassed();

    /// @dev Reverts when claim would exceed vesting total amount
    error CantClaimMoreThanTotalAmount();

    /// @dev Reverts when ERC20 transfer in withdrawUnallocated fails
    error WithdrawTransferFailed();

    /// @dev Reverts when there are no unallocated tokens to withdraw
    error NothingToWithdraw();

    // ----------------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------------

    /// @notice Emitted when a new vesting schedule is created
    /// @param beneficiary Address that receives vested tokens
    /// @param amount Total amount allocated to this vesting schedule
    /// @param creationTime Block timestamp when schedule was created
    event VestingCreated(address beneficiary, uint256 amount, uint256 creationTime);

    /// @notice Emitted when owner withdraws unallocated tokens from contract
    /// @param to Receiver of withdrawn tokens
    /// @param amount Amount withdrawn
    event TokensWithdrawn(address to, uint256 amount);

    /// @notice Emitted when beneficiary successfully claims vested tokens
    /// @param beneficiary Address that received the claimed tokens
    /// @param amount Amount claimed
    /// @param timestamp Block timestamp when claim happened
    event Claim(address beneficiary, uint256 amount, uint256 timestamp);

    // ----------------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------------

    /// @notice Claims currently available vested tokens for caller
    function claim() external;

    /// @notice Returns amount currently claimable by beneficiary
    /// @param _claimer Address to check
    /// @return Claimable token amount
    function claimableAmount(address _claimer) external view returns (uint256);

    /// @notice Creates vesting schedule for beneficiary
    /// @param _beneficiary Address that will receive vested tokens
    /// @param _totalAmount Total amount to vest
    /// @param _startTime Vesting start timestamp
    /// @param _cliff Cliff duration in seconds after startTime
    /// @param _duration Total vesting duration in seconds
    /// @param _claimCooldown Minimum seconds between claims
    /// @param _minClaimAmount Minimum amount allowed per claim
    function startVesting(
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _startTime,
        uint256 _cliff,
        uint256 _duration,
        uint256 _claimCooldown,
        uint256 _minClaimAmount
    ) external;

    /// @notice Withdraws tokens that are not allocated to active vesting schedules
    /// @param _to Receiver of withdrawn tokens
    function withdrawUnallocated(address _to) external;

    /// @notice Builds initialize calldata for DeployManager clone deployment
    /// @param _deployManager DeployManager address
    /// @param _token ERC20 token used for vesting
    /// @param _owner Owner of deployed vesting contract
    /// @return Encoded init data for initialize
    function getInitData(address _deployManager, address _token, address _owner) external pure returns (bytes memory);
}
