// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


contract CrowdFund{
    struct Campaign{
        uint campaignId;
        string campaignTitle;
        uint fundingGoal;
        uint duration;
        address campaignOwner;
        uint campaignBalance;
        bool isActive;
        address[] contributors;
       
    }
  
    mapping (uint  =>  mapping(address => uint )) contributorBalance;
    mapping (address => bool)  isContributor;
    mapping (uint => Campaign) public mapCampaign;
     uint public CampaignId;
     uint deployTime; 
     address deployer;   
    constructor (){
       deployTime = block.timestamp ;
       deployer = msg.sender;
    }



  function createCampaigns(uint _duration, uint _fundingGoal, string memory _campaignTitle) public returns (uint){
    CampaignId++;
     Campaign storage  campaign = mapCampaign[CampaignId];
     campaign.campaignId = CampaignId;
     campaign.campaignTitle = _campaignTitle;
     campaign.duration =   _duration;
     campaign.fundingGoal = _fundingGoal;
     campaign.campaignOwner = msg.sender;
     campaign.isActive = true;
    return (CampaignId);
    }
    
    modifier activeTime(uint _Id){
        require(block.timestamp <= ( mapCampaign[_Id].duration ) , "time passed");
      _;
    }
    function payCampaign(uint _CampaignId) public payable activeTime(CampaignId) {
      Campaign storage  campaign = mapCampaign[_CampaignId];
      require(campaign.isActive, "campaign is no longer active");
        campaign.campaignBalance += msg.value;
       contributorBalance[_CampaignId][msg.sender] +=msg.value;
       if( isContributor[msg.sender] == false){
      campaign.contributors.push(msg.sender);
       }
        isContributor[msg.sender] = true;
    }
     function refundContributors(uint _CampaignId ) public   returns (string memory ){
        Campaign storage  campaign = mapCampaign[_CampaignId];
      require(campaign.duration  < block.timestamp, "time e o yi pe, pada wa ");
      require(campaign.campaignBalance < campaign.fundingGoal, "campaign goal reached");
      require(contributorBalance[CampaignId][msg.sender] > 0, "you do not have money in this campaign");
      campaign.isActive = false;
      string memory successMessage;

      for (uint i = 0; i < campaign.contributors.length; i++) {
          if  (campaign.contributors[i] == msg.sender){
           address contributor = campaign.contributors[i] ;
           uint userBalance = contributorBalance[_CampaignId][msg.sender];
           payable(contributor).transfer(userBalance);
           contributorBalance[_CampaignId][contributor] -= contributorBalance[_CampaignId][msg.sender] ;
           campaign.campaignBalance -= userBalance;
        }
      }
      return (successMessage = "Sorry we have to refund, goal not reached");
     }
      function getAllCampaign() public view returns(Campaign[] memory)  {
      Campaign[] memory all = new Campaign[](CampaignId);
      for (uint i =0 ; i < CampaignId; i++) {
        all[i] = mapCampaign[i+1];
      }
      return  all; 
    }
     function payCampaignOwner(uint _CampaignId) public  returns ( string memory){
       Campaign storage  campaign = mapCampaign[_CampaignId];
      require(campaign.campaignBalance >= campaign.fundingGoal, "goal not reached");
      string memory successMessage;
      address owner = campaign.campaignOwner;
      payable(owner).transfer(campaign.campaignBalance);
      campaign.campaignBalance  = 0;   
      campaign.isActive = false;
      return(successMessage = "Congratulations");   
     }
   
   function getContributors( uint _CampaignId) public view returns (address[] memory) {
    return  ( mapCampaign[_CampaignId].contributors); 
    }
   function getContributorsBalance(address _addr, uint _CampaignId) public view returns (uint) {
      return       contributorBalance[_CampaignId][_addr];
   }
}
