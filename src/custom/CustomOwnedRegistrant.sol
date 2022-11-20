// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IOperatorFilterRegistry} from "./../IOperatorFilterRegistry.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";

/**
 * @title  CustomOwnedRegistrant
 * @notice Ownable contract that registers itself with the custom OperatorFilterRegistry and administers its own entries,
 *         to facilitate a subscription whose ownership can be transferred.
 */
contract CustomOwnedRegistrant is Ownable2Step {

    constructor(address registry) {
        IOperatorFilterRegistry(registry).register(address(this));
    }
}
