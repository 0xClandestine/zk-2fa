// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

error InvalidProof();
error CallerIsNotOwner();
error NullifierAlreadySpent();

abstract contract TwoFactorAuth is Verifier {

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    address public owner;

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

    constructor(address _owner, uint256 _secretHash) {
        secretHash = _secretHash;

        owner = _owner;
        
        emit OwnerUpdated(address(0), _owner);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    function setOwner(
        address newOwner,
        uint256 nullifierHash,
        Proof memory proof
    ) public virtual usingTwoFactorAuth(proof, nullifierHash) {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}