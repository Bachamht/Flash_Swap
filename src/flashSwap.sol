// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./uniswapV2_core/UniswapV2Pair.sol";
import {UniswapV2Router02} from "../src/uniswapV2_periphery/UniswapV2Router02.sol";
import {CGAToken} from "../src/CGAToken.sol";
import {CGBToken} from "../src/CGBToken.sol";
import {IUniswapV2Factory} from "./uniswapV2_core/interfaces/IUniswapV2Factory.sol";
import {UniswapV2Pair} from "./uniswapV2_core/UniswapV2Pair.sol";
import {UniswapV2Library} from "../src/uniswapV2_periphery/libraries/UniswapV2Library.sol";

contract FlashSwap {

    address private constant factory1 = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant factory2 = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant CGAAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant CGBAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant router1 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant router2 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private pair1;
    address private pair2;
    
    constructor() {
        pair1 = IUniswapV2Factory(factory1).getPair(CGAAddress, CGBAddress);
        pair2 = IUniswapV2Factory(factory2).getPair(CGAAddress, CGBAddress);
    }

    
    function flashLoan(uint CGATokenAmount) external {
        bytes memory data = abi.encode(CGAAddress, CGBAddress, CGATokenAmount);
        UniswapV2Pair(pair1).swap(CGATokenAmount, 0, address(this), data);
    }

    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        //Make sure it's the right pair to call the contract
        address token0 = IUniswapV2Pair(msg.sender).token0(); 
        address token1 = IUniswapV2Pair(msg.sender).token1(); 
        assert(msg.sender == IUniswapV2Factory(factory1).getPair(token0, token1)); 

        (address CGAPair2, address CGBPair2, uint256 lendAmounut) = abi.decode(data, (address, address, uint256));
        address [] memory path;
        path[0] = CGAPair2;
        path[1] = CGBPair2;
        uint256 CGAAmount = CGAToken(CGAAddress).balanceOf(address(this));
        UniswapV2Router02(payable(router2)).swapExactTokensForTokens(CGAAmount, 9000, path, address(this), block.timestamp + 60);
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory1, CGAAddress, CGBAddress);
        uint amountRepayment = UniswapV2Router02(payable(router2)).getAmountIn(lendAmounut, reserveA, reserveB);
        CGBToken(CGBAddress).transfer(router1, amountRepayment);
    }
}
