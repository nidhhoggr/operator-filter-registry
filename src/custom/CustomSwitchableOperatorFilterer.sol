// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CustomOperatorFilterer} from "./CustomOperatorFilterer.sol";

/**
 * @title  CustomSwitchableOperatorFilterer
 * @notice This contract is meant to allow contracts to opt out of the OperatorFilterRegistry. The Registry
 *         itself has an "unregister" function, but if the contract is ownable, the owner can re-register at any point.
 *         As implemented, this abstract contract allows the contract owner to toggle the
 *         isOperatorFilterRegistryEnabled flag in order to bypass the OperatorFilterRegistry checks.
 */
abstract contract CustomSwitchableOperatorFilterer is CustomOperatorFilterer {
    error OnlyOwner();

    bool private _isOperatorFilterRegistryEnabled = true;

    modifier onlyAllowedOperator(address from) override {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (!_isOperatorFilterRegistryEnabled && address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            // Allow spending tokens from addresses with balance
            // Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred
            // from an EOA.
            if (from == msg.sender) {
                _;
                return;
            }
            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), msg.sender)) {
                revert OperatorNotAllowed(msg.sender);
            }
        }
        _;
    }

    modifier onlyAllowedOperatorApproval(address operator) override {
        // Check registry code length to facilitate testing in environments without a deployed registry.
        if (!_isOperatorFilterRegistryEnabled && address(OPERATOR_FILTER_REGISTRY).code.length > 0) {
            if (!OPERATOR_FILTER_REGISTRY.isOperatorAllowed(address(this), operator)) {
                revert OperatorNotAllowed(operator);
            }
        }
        _;
    }

    /**
     * @notice Toggle the isOperatorFilterRegistryEnabled flag. OnlyOwner.
     */
    function toggleOperatorFilterRegistry() external {
        if (msg.sender != owner()) {
            revert OnlyOwner();
        }
        _isOperatorFilterRegistryEnabled = !_isOperatorFilterRegistryEnabled;
    }

    function isOperatorFilterRegistryEnabled() public view returns (bool) {
        return _isOperatorFilterRegistryEnabled;
    }

    /**
     * @dev assume the contract has an owner, but leave specific Ownable implementation up to inheriting contract
     */
    function owner() public view virtual returns (address);
}

