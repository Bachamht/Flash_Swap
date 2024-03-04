// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/flashSwap.sol";
import {UniswapV2Factory} from "../src/uniswapV2_core/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/uniswapV2_core/UniswapV2Pair.sol";
import {UniswapV2Router02} from "../src/uniswapV2_periphery/UniswapV2Router02.sol";
import {CGAToken} from "../src/CGAToken.sol";
import {CGBToken} from "../src/CGBToken.sol";
import {FlashSwap} from "../src/flashSwap.sol";
import "../src/flashSwap.sol";



contract UniswapV2FlashloanTest is Test {

    address private constant CGAAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant CGBAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant factory1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant factory2 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant router1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant router2 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant flashswap = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address admin = makeAddr("myadmin");
    address player = makeAddr("player");

    function setUp() public {
        vm.startPrank(admin);
        CGAToken(CGAAddress).mintTo(admin, 100000);
        CGBToken(CGBAddress).mintTo(admin, 100000);
        addLiquidityPairone();
        addLiquidityPairTwo();
        FlashSwap(flashswap).flashLoan(100);
        vm.stopPrank();
    }

    

    function addLiquidityPairone() public {
        vm.startPrank(admin);
        address pair1 = UniswapV2Factory(factory1).createPair(CGAAddress, CGBAddress);
        CGAToken(CGAAddress).transfer(router1, 500);
        CGBToken(CGBAddress).transfer(router1, 10000);
        UniswapV2Router02(payable(router1)).addLiquidity(CGAAddress, CGBAddress, 500, 10000, 500, 10000, admin, block.timestamp + 60);
        vm.stopPrank();
    }

    function addLiquidityPairTwo() public {
        vm.startPrank(admin);
        address pair1 = UniswapV2Factory(factory2).createPair(CGAAddress, CGBAddress);
        CGAToken(CGAAddress).transfer(router1, 100);
        CGBToken(CGBAddress).transfer(router1, 10000);
        UniswapV2Router02(payable(router1)).addLiquidity(CGAAddress, CGBAddress, 100, 10000, 100, 10000, admin, block.timestamp + 60);
        vm.stopPrank();
    }



}