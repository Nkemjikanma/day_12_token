// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Tokem} from "../src/Tokem.sol";
import {TokemLaunch} from "../src/TokemLaunch.sol";

contract TokemScript is Script {
    Tokem public tokem;
    TokemLaunch public tokemLaunch;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        tokem = new Tokem();
        tokemLaunch = new TokemLaunch(address(tokem));

        vm.stopBroadcast();
    }
}
