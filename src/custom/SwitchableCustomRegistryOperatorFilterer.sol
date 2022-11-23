// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CustomRegistryOperatorFilterer} from "./CustomRegistryOperatorFilterer.sol";

/**
 * @title  SwitchableCustomRegistryOperatorFilterer
 * @notice This contract is meant to allow contracts to opt out of the OperatorFilterRegistry. The Registry
 *         itself has an "unregister" function, but if the contract is ownable, the owner can re-register at any point.
 *         As implemented, this abstract contract allows the contract owner to toggle the
 *         isOperatorFilterRegistryEnabled flag in order to bypass the OperatorFilterRegistry checks.
 */
abstract contract SwitchableCustomRegistryOperatorFilterer is CustomRegistryOperatorFilterer {
    error OnlyOwner();

    bool private _isOperatorFilterRegistryEnabled = true;

    function _checkFilterOperator(address operator) internal view virtual override {
        if (_isOperatorFilterRegistryEnabled) {
            super._checkFilterOperator(operator);
        }
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

