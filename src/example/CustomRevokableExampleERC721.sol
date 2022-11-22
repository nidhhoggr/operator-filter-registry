// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {IOperatorFilterRegistry} from  "../IOperatorFilterRegistry.sol";
import {CustomRevokableOperatorFilterer} from "../custom/CustomRevokableOperatorFilterer.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title  CustomRevokableExampleERC721
 * @notice This example contract is configured to use the CustomRevokableOperatorFilterer, which automatically
 *         registers the token and subscribes it to a custom curated filters. The owner of the contract can
 *         permanently revoke checks to the filter registry by calling revokeOperatorFilterRegistry.
 *         Adding the onlyAllowedOperator modifier to the transferFrom and both safeTransferFrom methods ensures that
 *         the msg.sender (operator) is allowed by the OperatorFilterRegistry. Adding the onlyAllowedOperatorApproval
 *         modifier to the approval methods ensures that owners do not approve operators that are not allowed.
 */
abstract contract CustomRevokableExampleERC721 is ERC721("Example", "EXAMPLE"), CustomRevokableOperatorFilterer, Ownable {
    
    address public currentOperatorFiltererRegistry = 0x000000000000AAeB6D7670E522A718067333cd4E;

    address public currentOperatorFiltererSubscriber = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;

    function setOperatorFiltererRegistry(address _registry, address _registrant, bool subscribe) public onlyOwner {
        OPERATOR_FILTER_REGISTRY.unregister(address(this));
        currentOperatorFiltererRegistry = _registry;
        OPERATOR_FILTER_REGISTRY = IOperatorFilterRegistry(_registry);
        if (subscribe) {
            OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), _registrant);
        } 
        else {
            if (_registrant != address(0)) {
                OPERATOR_FILTER_REGISTRY.registerAndCopyEntries(address(this), _registrant);
            } 
            else {
                OPERATOR_FILTER_REGISTRY.register(address(this));
            }
        }
    }

    function setOperatorFiltererSubscriber(address _subscriber) public onlyOwner {
        OPERATOR_FILTER_REGISTRY.unregister(address(this));
        OPERATOR_FILTER_REGISTRY.registerAndSubscribe(address(this), _subscriber);
        currentOperatorFiltererSubscriber = _subscriber;
    }
   
   function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override
        onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function owner() public view virtual override (Ownable, CustomRevokableOperatorFilterer) returns (address) {
        return Ownable.owner();
    }
}
