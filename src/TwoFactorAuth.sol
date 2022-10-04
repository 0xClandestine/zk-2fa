// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

abstract contract TwoFactorAuth is Verifier {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    uint256 public secretHash;

    address public owner;

    mapping(uint256 => bool) public nullifierSpent;

    modifier onlyOwner(
        uint256 nullifierHash,
        Proof memory proof
    ) virtual {

        uint256[] memory inputs = new uint256[](2);

        inputs[0] = secretHash;
        inputs[1] = nullifierHash;

        require(
            msg.sender == owner && 
            verify(inputs, proof) == 1 && 
            !nullifierSpent[nullifierHash], 
            "UNAUTHORIZED"
        );

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
    ) public virtual onlyOwner(nullifierHash, proof) {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}