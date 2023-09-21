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
        mapping (address => uint) contributorBalance;
    }
    mapping (address => bool)  isContributor;
    mapping (uint => Campaign) mapCampaign;
     uint CampaignId;
     uint deployTime; 
     address deployer;   
    constructor (){
       deployTime = block.timestamp ;
       deployer = msg.sender;
    }

  function createCampaigns(uint _duration, uint _fundingGoal, string memory _campaignTitle) public {
    CampaignId++;
    mapCampaign[CampaignId].campaignId = CampaignId;
    mapCampaign[CampaignId].campaignTitle = _campaignTitle;
    mapCampaign[CampaignId].duration =   _duration;
    mapCampaign[CampaignId].fundingGoal = _fundingGoal;
    mapCampaign[CampaignId].campaignOwner = msg.sender;
    mapCampaign[CampaignId].isActive = true;
    }
    modifier activeTime(uint _Id){
        require(block.timestamp <= ( mapCampaign[_Id].duration ) , "time passed");
      _;
    }
    function payCampaign(uint _CampaignId) public payable activeTime(CampaignId) {
      require(mapCampaign[_CampaignId].isActive, "campaign is no longer active");
       mapCampaign[ _CampaignId].campaignBalance += msg.value;
       mapCampaign[ _CampaignId].contributorBalance[msg.sender]+= msg.value;
       if( isContributor[msg.sender] == false){
       mapCampaign[ _CampaignId].contributors.push(msg.sender);
       }
        isContributor[msg.sender] = true;

    }
     function refundContributors(uint _CampaignId ) public   returns (string memory ){
      require(mapCampaign[_CampaignId].duration  < block.timestamp, "time e o yi pe, pada wa ");
      require(mapCampaign[_CampaignId].campaignBalance < mapCampaign[_CampaignId].fundingGoal, "campaign goal reached");
      require(mapCampaign[CampaignId].contributorBalance[msg.sender] > 0, "you do not have money in this campaign");
      mapCampaign[_CampaignId].isActive = false;
      string memory successMessage;
    
    
      mapCampaign[CampaignId].campaignBalance   -=   mapCampaign[CampaignId].contributorBalance[msg.sender] ;
      mapCampaign[CampaignId].contributorBalance[msg.sender] -= mapCampaign[CampaignId].contributorBalance[msg.sender] ;
      uint userBalance = mapCampaign[CampaignId].contributorBalance[msg.sender];

      for (uint i = 0; i < mapCampaign[_CampaignId].contributors.length; i++) {
            address contributor = mapCampaign[_CampaignId].contributors[i];
      payable(contributor).transfer(userBalance);
            mapCampaign[_CampaignId].contributorBalance[contributor] = 0;
        }
      return (successMessage = "Sorry we have to refund, goal not reached");
     }

     function payCampaignOwner(uint _CampaignId) public  returns ( string memory){
      require(mapCampaign[_CampaignId].campaignBalance >= mapCampaign[_CampaignId].fundingGoal, "goal not reached");
      string memory successMessage;
      address owner = mapCampaign[_CampaignId].campaignOwner;
      payable(owner).transfer(mapCampaign[_CampaignId].campaignBalance);
       mapCampaign[_CampaignId].campaignBalance  = 0;   
      mapCampaign[_CampaignId].isActive = false;
         return(successMessage = "Congratulations"); 
         
     }
    function getCampaign(uint _campaignId) public view returns( string memory, uint, uint, uint, uint){
     return (mapCampaign[_campaignId].campaignTitle, mapCampaign[_campaignId].duration,mapCampaign[_campaignId].fundingGoal, mapCampaign[_campaignId].campaignId,   mapCampaign[_campaignId].campaignBalance );
    }
   function getContributors(uint index, uint _CampaignId) public view returns (address) {
    return  ( mapCampaign[_CampaignId].contributors[index]); 
    }
   function getContributorsBalance(address _addr, uint _CampaignId) public view returns (uint) {
      return   mapCampaign[_CampaignId].contributorBalance[_addr];
   }
}
