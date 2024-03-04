pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import {CGAToken} from "../src/CGAToken.sol";
import {CGBToken} from "../src/CGBToken.sol";

contract UniswapV2Deploy is Script {
    function setUp() public {}
    function run() public {
        address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY_LOCAL"));
        vm.startBroadcast(deployer);
        CGAToken cga = new CGAToken(); 
        CGBToken cgb = new CGBToken();
        console.log(address(cga));
        console.log(address(cgb));
    }
}