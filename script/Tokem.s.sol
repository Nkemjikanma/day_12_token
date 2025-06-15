// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Tokem} from "../src/Tokem.sol";

contract TokemScript is Script {
    // Counter public counter;
    Tokem public tokem;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        tokem = new Tokem();

        vm.stopBroadcast();
    }
}
