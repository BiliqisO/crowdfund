// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
// import "forge-std/Test.sol";
import {CrowdFund} from "../contracts/crowdfund.sol";
// import "forge-std/src/Test.sol";

import {Test, console2} from "../lib/forge-std/src/Test.sol";

contract CounterTest is Test {
    CrowdFund crowdFund;

    function setUp() public {
        crowdFund = new CrowdFund();
    }

    function testCreateCampaign() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(0, 4 ether, "Baby");
        assertEq(crowdFund.CampaignId(), 1);
    }

    function testPayCampaign() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 5 ether);
        crowdFund.payCampaign{value: 5 ether}(1);
        assertEq(crowdFund.getMap(1).campaignBalance, 5 ether);
    }

    function testFailActiveTime() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 5 ether);
        vm.warp(1697230790);
        crowdFund.payCampaign{value: 5 ether}(1);
        vm.expectRevert("time has passed");
    }

    function testContributorBalance() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 5 ether);
        crowdFund.payCampaign{value: 5 ether}(1);
        vm.stopPrank();
        assertTrue(crowdFund.getContributorsBalance(address(2), 1) == 5 ether);
    }

    function testRefundContributorsUser1() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdFund.payCampaign{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(address(3));
        vm.deal(address(3), 2 ether);
        crowdFund.payCampaign{value: 2 ether}(1);
        vm.stopPrank();
        vm.startPrank(address(2));
        vm.warp(1697230790);
        crowdFund.refundContributors(1);
        assertEq(crowdFund.getMap(1).campaignBalance, 2 ether);
    }

    function testRefundContributorsUser2() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdFund.payCampaign{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(address(3));
        vm.deal(address(3), 2 ether);
        crowdFund.payCampaign{value: 2 ether}(1);

        vm.warp(1697230790);
        crowdFund.refundContributors(1);
        assertEq(crowdFund.getMap(1).campaignBalance, 1 ether);
    }

    function testPayCampaignOwner() public {
        vm.prank(address(0x1111));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdFund.payCampaign{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(address(3));
        vm.deal(address(3), 6 ether);
        crowdFund.payCampaign{value: 6 ether}(1);
        vm.stopPrank();
        crowdFund.payCampaignOwner(1);
        assertEq(crowdFund.getMap(1).campaignBalance, 0 ether);
    }

    function testFailPayCampaignOwner() public {
        vm.prank(address(0x1111));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdFund.payCampaign{value: 1 ether}(1);
        vm.stopPrank();

        vm.startPrank(address(3));
        vm.deal(address(3), 4 ether);
        crowdFund.payCampaign{value: 4 ether}(1);
        vm.stopPrank();

        vm.prank(address(1));
        crowdFund.payCampaignOwner(2);
        vm.expectRevert("campaign not active");
    }

    function testFailRefundContributors() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 5 ether);
        crowdFund.payCampaign{value: 5 ether}(1);
        vm.stopPrank();
        crowdFund.refundContributors(1);
        vm.expectRevert("campaign is on, refund not yet activated");
    }

    function testFailActiveCampaign() public {
        vm.prank(address(1));
        crowdFund.createCampaigns(1697230787, 4 ether, "Baby");
        vm.startPrank(address(2));
        vm.deal(address(2), 1 ether);
        crowdFund.payCampaign{value: 1 ether}(1);
        vm.stopPrank();
        vm.startPrank(address(3));
        vm.deal(address(3), 2 ether);
        crowdFund.payCampaign{value: 2 ether}(1);
        vm.warp(1697230790);
        crowdFund.refundContributors(1);
        vm.startPrank(address(4));
        vm.deal(address(4), 2 ether);
        vm.warp(1697230787);
        crowdFund.payCampaign{value: 2 ether}(1);
        assertEq(crowdFund.getMap(1).campaignBalance, 1 ether);
    }
}
