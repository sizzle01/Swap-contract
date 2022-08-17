// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Swap is ERC20 {

  address public hotCoin;

    // Swap is inheriting ERC20, because our exchange would keep track of  tokens
    constructor(address _ownerAddress) ERC20("CryptoDev LP Token", "CDLP") {
        require(_ownerAddress != address(0), "Token address passed is a null address");
        hotCoin = _ownerAddress;
    }

    function getReserve() public view returns (uint) {
    return ERC20(hotCoin).balanceOf(address(this));
}

function getAmountOfTokens(
    uint256 inputAmount,
    uint256 inputReserve,
    uint256 outputReserve
) public pure returns (uint256) {
    require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
    // I am charging a fee of `1%`
   
    uint256 inputAmountWithFee = inputAmount * 99;
    // following  the concept of `XY = K` curve
   
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
    return numerator / denominator;
}

function ethToHotCoin(uint _minTokens) public payable {
    uint256 tokenReserve = getReserve();
    // invoke `getAmountOfTokens` to get the amount of Crypto Dev tokens
    // that would be returned to the user after the swap
    // Notice that the `inputReserve` we are sending is equal to  
    // `address(this).balance - msg.value` instead of just `address(this).balance`
    uint256 tokensBought = getAmountOfTokens(
        msg.value,
        address(this).balance - msg.value,
        tokenReserve
    );

    require(tokensBought >= _minTokens, "insufficient output amount");
    // Transfer the `Crypto Dev` tokens to the user
    ERC20(hotCoin).transfer(msg.sender, tokensBought);
}

function cryptoHotCoinToEth(uint _tokensSold, uint _minEth) public {
    uint256 tokenReserve = getReserve();
    // call the `getAmountOfTokens` to get the amount of Eth
    // that would be returned to the user after the swap
    uint256 ethBought = getAmountOfTokens(
        _tokensSold,
        tokenReserve,
        address(this).balance
    );
    require(ethBought >= _minEth, "insufficient output amount");
    // Transfer `Crypto Dev` tokens from the user's address to the contract
    ERC20(hotCoin).transferFrom(
        msg.sender,
        address(this),
        _tokensSold
    );
    // send the `ethBought` to the user from the contract
    payable(msg.sender).transfer(ethBought);
}

}