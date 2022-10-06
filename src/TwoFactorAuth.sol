// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

error InvalidProof();
error CallerIsNotOwner();
error NullifierAlreadySpent();

/// @notice Single owner authorization with zk-based two-factor-authorization mixin.
/// @author Modified from SolBase (https://github.com/Sol-DAO/solbase/blob/main/src/auth/OwnedThreeStep.sol)
abstract contract TwoFactorAuth is Verifier {

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnerUpdateInitiated(address indexed user, address indexed ownerCandidate);

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    address public owner;

    address public ownerCandidate;

    uint256 public secretHash;

    mapping(uint256 => bool) public nullifierSpent;

    modifier usingTwoFactorAuth(
        Proof memory proof,
        uint256 nullifierHash
    ) virtual {

        uint256[] memory inputs = new uint256[](2);

        inputs[0] = secretHash;
        inputs[1] = nullifierHash;

        if (msg.sender != owner) revert CallerIsNotOwner();
        if (!verifyProof(proof, secretHash, nullifierHash)) revert InvalidProof();
        if (nullifierSpent[nullifierHash]) revert NullifierAlreadySpent();

        nullifierSpent[nullifierHash] = true;
        
        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /// @notice Create contract and set `owner`.
    /// @param _owner The `owner` of contract.
    constructor(address _owner, uint256 _secretHash) {
        owner = _owner;
        secretHash = _secretHash;

        emit OwnerUpdated(address(0), _owner);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    /// @notice Initiate ownership transfer.
    /// @param newOwner The `_ownerCandidate` that will `confirmOwner()`.
    function setOwner(
        Proof memory proof, 
        uint256 nullifierHash, 
        address newOwner
    ) public virtual usingTwoFactorAuth(proof, nullifierHash) {
        ownerCandidate = newOwner;

        emit OwnerUpdateInitiated(msg.sender, newOwner);
    }

    /// @notice Confirm ownership between `owner` and `_ownerCandidate`.
    function confirmOwner(
        Proof memory proof,
        uint256 newSecretHash,
        uint256 nullifierHash
    ) public virtual {

        if (msg.sender != ownerCandidate) revert CallerIsNotOwner();
        if (!verifyProof(proof, secretHash, nullifierHash)) revert InvalidProof();

        delete ownerCandidate;
        owner = msg.sender;
        secretHash = newSecretHash;

        emit OwnerUpdated(msg.sender, msg.sender);
    }

    /// @notice Terminate ownership by `owner`.
    function renounceOwner(
        Proof memory proof, 
        uint256 nullifierHash
    ) public virtual usingTwoFactorAuth(proof, nullifierHash) {
        delete owner;

        emit OwnerUpdated(msg.sender, address(0));
    }
}