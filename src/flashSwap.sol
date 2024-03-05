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

    address private factory1;
    address private factory2;
    address private CGAAddress;
    address private CGBAddress;
    address private router1;
    address private router2;

    constructor(address _factory1, address _factory2, address _CGAAddress, address _CGBAddress, address _router1, address _router2){
        factory1 = _factory1;
        factory2 = _factory2;
        CGAAddress = _CGAAddress;
        CGBAddress = _CGBAddress;
        router1 = _router1;
        router2 = _router2;
    }
    
    function flashLoan(uint CGATokenAmount) external {
        address pair1 = IUniswapV2Factory(factory1).getPair(CGAAddress, CGBAddress);
        bytes memory data = abi.encode(CGATokenAmount);
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

        //Swap out tokens from another trading pair
        (uint256 lendAmounut) = abi.decode(data, (uint256));
        address [] memory path = new address [](2);
        path[0] = CGAAddress;
        path[1] = CGBAddress;
        uint256 CGAAmount = CGAToken(CGAAddress).balanceOf(address(this));
        CGAToken(CGAAddress).approve(address(router2), CGAAmount);
        UniswapV2Router02(payable(router2)).swapExactTokensForTokens(CGAAmount, 3000, path, address(this), block.timestamp + 60);

        //Calculate the amount due and make repayments
        address pair1 = IUniswapV2Factory(factory1).getPair(CGAAddress, CGBAddress);
        (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(factory1, CGAAddress, CGBAddress);
        uint amountRepayment = UniswapV2Router02(payable(router1)).getAmountIn(100, 10000, 500);
        CGBToken(CGBAddress).transfer(pair1, amountRepayment);
    }
}
