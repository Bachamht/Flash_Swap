pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/uniswapV2_core/UniswapV2Factory.sol";
import {UniswapV2Router02} from "../src/uniswapV2_periphery/UniswapV2Router02.sol";
import {WETH9} from "../src/uniswapV2_periphery/WETH9.sol";
import {UniswapV2Pair} from "../src/uniswapV2_core/UniswapV2Pair.sol";
import {CGAToken} from "../src/CGAToken.sol";
import {CGBToken} from "../src/CGBToken.sol";
import {FlashSwap} from "../src/flashSwap.sol";

contract UniswapV2Deploy is Script {

    address private constant CGAAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant CGBAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant factory1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant factory2 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant router1 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant router2 = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant flashswap = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address player;
   
    function setUp() public {
        player = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
    }
    function run() public {
        vm.startBroadcast(player);
        addLiquidityPairone();
        addLiquidityPairTwo();
        FlashSwap(flashswap).flashLoan(100);
        vm.stopBroadcast();
    }


    function addLiquidityPairone() public {
        address pair1 = UniswapV2Factory(factory1).createPair(CGAAddress, CGBAddress);
        CGAToken(CGAAddress).approve(router1, 500);
        CGBToken(CGBAddress).approve(router1, 10000);
        UniswapV2Router02(payable(router1)).addLiquidity(CGAAddress, CGBAddress, 500, 10000, 500, 10000, player, block.timestamp + 60);
    }

    function addLiquidityPairTwo() public {
        address pair2 = UniswapV2Factory(factory2).createPair(CGAAddress, CGBAddress);
        CGAToken(CGAAddress).approve(router2, 200);
        CGBToken(CGBAddress).approve(router2, 10000);
        UniswapV2Router02(payable(router2)).addLiquidity(CGAAddress, CGBAddress, 200, 10000, 200, 10000, player, block.timestamp + 60);
    }



}