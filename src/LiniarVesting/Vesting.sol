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

    /// @notice Per-beneficiary vesting schedule data
    struct VestingInfo {
        /// @dev Total amount allocated for this beneficiary
        uint256 totalAmount;

        /// @dev Vesting start timestamp
        uint256 startTime;

        /// @dev Cliff duration in seconds counted from startTime
        uint256 cliff;

        /// @dev Total linear vesting duration in seconds
        uint256 duration;

        /// @dev Total amount already claimed
        uint256 claimed;

        /// @dev Timestamp of last successful claim
        uint256 lastClaimTime;

        /// @dev Minimum seconds between two claims
        uint256 claimCooldown;

        /// @dev Minimum amount required to execute one claim
        uint256 minClaimAmount;
    }

    /// @notice Beneficiary address => vesting schedule
    mapping(address => VestingInfo) public vestings;

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
    function startVesting(
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _startTime,
        uint256 _cliff,
        uint256 _duration,
        uint256 _claimCooldown,
        uint256 _minClaimAmount
    ) external override onlyOwner {
        require(token.balanceOf(address(this)) - allocatedTokens >= _totalAmount, InfsufficientBalance());
        require(_totalAmount > 0, AmountCantBeZero());
        require(
            vestings[_beneficiary].totalAmount == 0
                || vestings[_beneficiary].totalAmount == vestings[_beneficiary].claimed,
            VestingAlreadyExist()
        );
        require(_startTime > block.timestamp, StartTimeShouldBeFuture());
        require(_duration > 0, DurationCantBeZero());
        require(_cliff < _duration, CliffCantBeLongerThanDuration());
        require(_claimCooldown < _duration, CooldownCantBeLongerThanDuration());
        require(_beneficiary != address(0), InvalidBeneficiary());

        vestings[_beneficiary] = VestingInfo({
            totalAmount: _totalAmount,
            startTime: _startTime,
            cliff: _cliff,
            duration: _duration,
            claimed: 0,
            lastClaimTime: 0,
            claimCooldown: _claimCooldown,
            minClaimAmount: _minClaimAmount
        });

        allocatedTokens = allocatedTokens + _totalAmount;

        emit VestingCreated(_beneficiary, _totalAmount, block.timestamp);
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
