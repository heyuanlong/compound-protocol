// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";

/**
 * @title Compound's CEther Contract
 * @notice CToken which wraps Ether
 * @author Compound
 */
contract CEther is CToken {

    constructor(ComptrollerInterface comptroller_,
                InterestRateModel interestRateModel_,
                uint initialExchangeRateMantissa_,
                string memory name_,
                string memory symbol_,
                uint8 decimals_,
                address payable admin_) {
        // Creator of the contract is admin during initialization
        admin = payable(msg.sender);
        initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        // Set the proper admin now that initialization is done
        admin = admin_;
    }


    function mint() external payable {
        mintInternal(msg.value);
    }

    function redeem(uint redeemTokens) external returns (uint) {
        redeemInternal(redeemTokens);
        return NO_ERROR;
    }

    function redeemUnderlying(uint redeemAmount) external returns (uint) {
        redeemUnderlyingInternal(redeemAmount);
        return NO_ERROR;
    }

    function borrow(uint borrowAmount) external returns (uint) {
        borrowInternal(borrowAmount);
        return NO_ERROR;
    }

    function repayBorrow() external payable {
        repayBorrowInternal(msg.value);
    }

    function repayBorrowBehalf(address borrower) external payable {
        repayBorrowBehalfInternal(borrower, msg.value);
    }

    function liquidateBorrow(address borrower, CToken cTokenCollateral) external payable {
        liquidateBorrowInternal(borrower, msg.value, cTokenCollateral);
    }

    function _addReserves() external payable returns (uint) {
        return _addReservesInternal(msg.value);
    }

    receive() external payable {
        mintInternal(msg.value);
    }

    function getCashPrior() override internal view returns (uint) {
        return address(this).balance - msg.value;
    }

    function doTransferIn(address from, uint amount) override internal returns (uint) {
        // Sanity checks
        require(msg.sender == from, "sender mismatch");
        require(msg.value == amount, "value mismatch");
        return amount;
    }

    function doTransferOut(address payable to, uint amount) virtual override internal {
        /* Send the Ether, with minimal gas and revert on failure */
        to.transfer(amount);
    }
}
