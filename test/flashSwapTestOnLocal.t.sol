// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/flashSwap.sol";
import {UniswapV2Factory} from "../src/uniswapV2_core/UniswapV2Factory.sol";
import {WETH9} from "../src/uniswapV2_periphery/WETH9.sol";
import {UniswapV2Pair} from "../src/uniswapV2_core/UniswapV2Pair.sol";
import {UniswapV2Router02} from "../src/uniswapV2_periphery/UniswapV2Router02.sol";
import {CGAToken} from "../src/CGAToken.sol";
import {CGBToken} from "../src/CGBToken.sol";
import {FlashSwap} from "../src/flashSwap.sol";
import "../src/flashSwap.sol";



contract FlashloanLocalTest is Test {


    CGAToken CGA;
    CGBToken CGB;
    UniswapV2Factory factory1;
    UniswapV2Factory factory2;
    UniswapV2Router02 router1;
    UniswapV2Router02 router2;
    WETH9 weth1;
    WETH9 weth2;
    FlashSwap flashswap;

    address admin = makeAddr("myadmin");
    address player = makeAddr("player");

    function setUp() public {
        vm.startPrank(admin);
        factory1 = new UniswapV2Factory(admin);
        factory2 = new UniswapV2Factory(admin);
        weth1 = new WETH9();
        weth2 = new WETH9();
        router1 = new UniswapV2Router02(address(factory1), address(weth1));
        router2 = new UniswapV2Router02(address(factory2), address(weth2));
        CGA = new CGAToken();
        CGB = new CGBToken();
        flashswap = new FlashSwap(address(factory1), address(factory2), address(CGA), address(CGB), address(router1), address(router2));
        CGA.mintTo(admin, 100000);
        CGB.mintTo(admin, 100000);
        vm.stopPrank();
    }

    function test() public {
        addLiquidityPairone();
        addLiquidityPairTwo();
        flashswap.flashLoan(100);
        console.log(CGB.balanceOf(address(flashswap)));
    }

    function addLiquidityPairone() public {
        vm.startPrank(admin);
        address pair1 = factory1.createPair(address(CGA), address(CGB));
        CGA.approve(address(router1), 500);
        CGB.approve(address(router1), 10000);
        router1.addLiquidity(address(CGA), address(CGB), 500, 10000, 500, 10000, admin, block.timestamp + 60);
        vm.stopPrank();
    }

    function addLiquidityPairTwo() public {
        vm.startPrank(admin);
        address pair2 = factory2.createPair(address(CGA), address(CGB));
        CGA.approve(address(router2), 200);
        CGB.approve(address(router2), 10000);
        router2.addLiquidity(address(CGA), address(CGB), 200, 10000, 200, 10000, admin, block.timestamp + 60);
        vm.stopPrank();
    }



}