//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Tokem} from "./Tokem.sol";

contract TokemLaunch is Tokem {
    error TokemLaunch__SaleIsNotActive();
    error TokenSale__InvalidRate();
    error TokenSale__ZeroAddress();
    error TokemSale__ZeroAmount();
    error TokenSale__BelowMinimumPurchase();
    error TokenSale__AboveMaximumPurchase();
    error TokemSale__InsufficientTokemBalance();
    error TokemSale__TransferFailed();
    error TokemSale__AllocationFinished();
    error TokemSale__Unauthorized();
    error TokemLaunch__SaleNotInPeriod();

    Tokem private tokem;

    uint256 public tokenPrice;
    bool public saleActive;
    address public ownerAddress;
    uint256 public totalSold;
    uint256 public tokenAllocation;
    uint256 public maxPurchase;
    uint256 public minPurchase;
    uint256 public saleStartTime;
    uint256 public saleEndTime; // depicted in seconds

    event InitialTransfer(bool status);
    event RateUpdated(uint256 _oldRate, uint256 _newRate);
    event TokemsPurchased(address indexed _buyer, uint256 _amountOfEth, uint256 _amountOfTokem);
    event SaleStatusChanged(bool saleActive);

    modifier whenSaleIsActive() {
        if (!saleActive) {
            revert TokemLaunch__SaleIsNotActive();
        }

        if (block.timestamp < saleStartTime || block.timestamp > saleEndTime) {
            revert TokemLaunch__SaleNotInPeriod();
        }

        _;

        //after block exectues, check if we need to update status
        checkAndUpdateSaleStatus();
    }

    modifier onlyOwner() {
        if (msg.sender != ownerAddress) {
            revert TokemSale__Unauthorized();
        }

        _;
    }

    constructor(address _tokem) {
        if (_tokem == address(0)) {
            revert TokenSale__ZeroAddress();
        }

        tokem = Tokem(_tokem);

        tokenPrice = 100;
        saleActive = true;
        ownerAddress = msg.sender;
        totalSold = 0;
        tokenAllocation = _totalSupply / 2;
        maxPurchase = 1000000000000000000;
        minPurchase = 10000000000000000;
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + 7 * 24 * 60 * 60; // 7 days in seconds

        // transfer all tokens to this contract
        _transfer(msg.sender, address(this), _totalSupply);

        emit InitialTransfer(true);
    }

    // function toggleSale() external onlyOwner {
    //     saleActive = !saleActive;
    //     emit SaleStatusChanged(saleActive);
    // }

    function buyTokens() public payable whenSaleIsActive {
        uint256 weiAmount = msg.value;

        if (weiAmount == 0) {
            revert TokemSale__ZeroAmount();
        }

        if (weiAmount < minPurchase) {
            revert TokenSale__BelowMinimumPurchase();
        }

        if (weiAmount > maxPurchase) {
            revert TokenSale__AboveMaximumPurchase();
        }

        // calculate token amoount;
        // weiAmount * tokenPrice / 1 ether
        uint256 tokenAmount = (weiAmount * tokenPrice) / 1 ether;

        if (totalSold + tokenAmount > tokenAllocation) {
            revert TokemSale__AllocationFinished();
        }

        if (balanceOf(address(this)) < tokenAmount) {
            revert TokemSale__InsufficientTokemBalance();
        }

        totalSold += tokenAmount;

        bool success = tokem.transfer(msg.sender, tokenAmount);

        if (!success) {
            revert TokemSale__TransferFailed();
        }

        emit TokemsPurchased(msg.sender, weiAmount, tokenAmount);
    }

    function checkAndUpdateSaleStatus() internal {
        if (totalSold >= tokenAllocation || block.timestamp > saleEndTime) {
            saleActive = false;
            emit SaleStatusChanged(false);
        }
    }

    /**
     * @dev Sets a new token rate
     * @param _newRate New token rate (tokens per ETH)
     */
    function setTokenPrice(uint256 _newRate) public onlyOwner {
        if (_newRate == 0) {
            revert TokenSale__InvalidRate();
        }

        uint256 oldRate = tokenPrice;
        tokenPrice = _newRate;

        emit RateUpdated(oldRate, _newRate);
        // 1 token is 0.01E
    }

    /**
     * @dev Returns the current token rate
     * @return The current token rate
     */
    function getTokenRate() external view returns (uint256) {
        return tokenPrice;
    }

    receive() external payable {
        if (saleActive) {
            buyTokens();
        }
    }
}
