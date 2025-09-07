// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Script, console} from "forge-std/Script.sol";
import {USDT} from "src/samples/USDT.sol";
import {Vault} from "src/Vault.sol";
import {QuestStorage} from "src/QuestStorage.sol";
import {Claimer} from "src/Claimer.sol";
import { IRewardProcessor } from "src/interfaces/IRewardProcessor.sol";


contract USDTScript is Script {
    USDT public usdt;
    Vault public vault;
    QuestStorage public questStorage;
    Claimer public claimer;
    IRewardProcessor public rewardProcessor;
    

    function run() public {
        vm.startBroadcast();

        rewardProcessor = IRewardProcessor(0x4BA7931cDc6cC5CAC70d804AAc6BF768B5133079);

        usdt = new USDT(msg.sender);
        usdt.mint(msg.sender, 1000000 ether);

        vault = new Vault(msg.sender);
        questStorage = new QuestStorage(msg.sender);
        claimer = new Claimer(msg.sender, msg.sender, vault, questStorage, rewardProcessor);

        questStorage.grantRole(questStorage.MANAGER_ROLE(), msg.sender);
        vault.grantRole(vault.CLAIMER_ROLE(), address(claimer));

        usdt.approve(address(vault), 1000000 ether);
        vault.topUp(usdt, 1000000 ether);

        console.log("USDT deployed to:", address(usdt));
        console.log("Vault deployed to:", address(vault));
        console.log("QuestStorage deployed to:", address(questStorage));
        console.log("Claimer deployed to:", address(claimer));

        vm.stopBroadcast();
    }
}
